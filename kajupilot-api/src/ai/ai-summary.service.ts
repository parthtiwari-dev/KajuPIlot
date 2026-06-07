import { Injectable, OnModuleDestroy, OnModuleInit } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { Queue, Worker } from "bullmq";
import Redis from "ioredis";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { InsightsService } from "../insights/insights.service";
import { PrismaService } from "../prisma/prisma.service";
import { AiService } from "./ai.service";

type CachedAiSummary = {
  text?: string;
  insights?: string[];
  generatedAt: string;
  provider: string;
  model: string;
  usage?: {
    inputTokens: number;
    outputTokens: number;
    estimatedCostUsd: number;
  };
};

const SUMMARY_QUEUE = "kajupilot-ai-summary";

@Injectable()
export class AiSummaryService implements OnModuleInit, OnModuleDestroy {
  private redis?: Redis;
  private queue?: Queue;
  private worker?: Worker;
  private readonly memoryCache = new Map<
    string,
    { expiresAt: number; value: CachedAiSummary }
  >();

  constructor(
    private readonly aiService: AiService,
    private readonly insightsService: InsightsService,
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {}

  onModuleInit() {
    if (this.configService.get<string>("NODE_ENV") === "test") {
      return;
    }

    if (!this.redisUrl()) {
      return;
    }

    const connection = this.bullConnectionOptions();
    this.queue = new Queue(SUMMARY_QUEUE, {
      connection,
    });
    this.worker = new Worker(
      SUMMARY_QUEUE,
      async () => {
        await this.generateDailySummaries();
      },
      { connection },
    );
    void this.queue.add(
      "daily-summary",
      {},
      {
        jobId: "daily-summary-7am-ist",
        repeat: { pattern: "30 1 * * *" },
        removeOnComplete: true,
        removeOnFail: 20,
      },
    );
  }

  async onModuleDestroy() {
    await this.worker?.close();
    await this.queue?.close();
    await this.redis?.quit();
  }

  async todaySummary(user: AuthenticatedUser, date?: string, refresh = false) {
    const active = this.aiService.getProviderSummary().active;
    const localDate = date ?? this.dateOnly(new Date());
    const cacheKey = this.cacheKey(
      "today",
      user.id,
      localDate,
      active.provider,
      active.model,
    );

    if (!refresh) {
      const cached = await this.getCached(cacheKey);
      if (cached) {
        return {
          ...cached,
          insights: this.cleanInsights(cached.insights),
          cached: true,
        };
      }
    }

    const today = await this.insightsService.today(user, localDate);
    const prompt = [
      "Write one concise business summary for today's cashew trading work.",
      "Be direct, practical, and mention specific calls or money if present.",
      "Use Indian rupee/lakh language. No markdown.",
      JSON.stringify({ date: localDate, today }),
    ].join("\n");

    try {
      const result = await this.aiService.generateText({ prompt });
      const summary: CachedAiSummary = {
        text: result.text || this.todayFallbackText(today),
        generatedAt: new Date().toISOString(),
        provider: result.provider,
        model: result.model,
        usage: result.usage,
      };
      await this.setCached(cacheKey, summary, 12 * 60 * 60);
      return { ...summary, cached: false };
    } catch {
      return {
        text: this.todayFallbackText(today),
        generatedAt: new Date().toISOString(),
        provider: active.provider,
        model: active.model,
        cached: false,
      };
    }
  }

  async weeklyInsights(user: AuthenticatedUser, to?: string, refresh = false) {
    const active = this.aiService.getProviderSummary().active;
    const toDate = to ?? this.dateOnly(new Date());
    const cacheKey = this.cacheKey(
      "weekly",
      user.id,
      toDate,
      active.provider,
      active.model,
    );

    if (!refresh) {
      const cached = await this.getCached(cacheKey);
      if (cached) {
        return { ...cached, cached: true };
      }
    }

    const [weekly, people] = await Promise.all([
      this.insightsService.weekly(user, toDate),
      this.insightsService.people(user, toDate),
    ]);
    const prompt = [
      "Return 3 to 5 sharp weekly business insights for an Indian cashew trader.",
      "Focus on money, slow payers, buyers, expenses, and concrete action.",
      'Output JSON only: { "insights": ["string"] }',
      JSON.stringify({ to: toDate, weekly, people }),
    ].join("\n");

    try {
      const result = await this.aiService.generateText({ prompt });
      const summary: CachedAiSummary = {
        insights: this.parseInsights(result.text),
        generatedAt: new Date().toISOString(),
        provider: result.provider,
        model: result.model,
        usage: result.usage,
      };
      await this.setCached(cacheKey, summary, 6 * 60 * 60);
      return { ...summary, cached: false };
    } catch {
      return {
        insights: this.weeklyFallbackInsights(weekly, people),
        generatedAt: new Date().toISOString(),
        provider: active.provider,
        model: active.model,
        cached: false,
      };
    }
  }

  private async generateDailySummaries() {
    const users = await this.prisma.user.findMany({
      select: { id: true, role: true, name: true, businessName: true },
    });
    const date = this.dateOnly(new Date());
    for (const user of users) {
      await this.todaySummary(
        {
          id: user.id,
          role: user.role,
          name: user.name,
          businessName: user.businessName,
        },
        date,
        true,
      );
    }
  }

  private async getCached(key: string) {
    try {
      if (this.redisUrl()) {
        const raw = await this.getRedis().get(key);
        return raw ? (JSON.parse(raw) as CachedAiSummary) : null;
      }
      const cached = this.memoryCache.get(key);
      if (!cached || cached.expiresAt < Date.now()) {
        this.memoryCache.delete(key);
        return null;
      }
      return cached.value;
    } catch {
      return null;
    }
  }

  private async setCached(
    key: string,
    value: CachedAiSummary,
    ttlSeconds: number,
  ) {
    try {
      if (this.redisUrl()) {
        await this.getRedis().set(key, JSON.stringify(value), "EX", ttlSeconds);
        return;
      }
      this.memoryCache.set(key, {
        value,
        expiresAt: Date.now() + ttlSeconds * 1000,
      });
    } catch {
      this.memoryCache.set(key, {
        value,
        expiresAt: Date.now() + ttlSeconds * 1000,
      });
    }
  }

  private getRedis() {
    this.redis ??= new Redis(this.redisUrl()!, {
      lazyConnect: false,
      maxRetriesPerRequest: 1,
    });
    return this.redis;
  }

  private parseInsights(text: string): string[] {
    const normalized = this.stripCodeFence(text.trim());
    try {
      const parsed = JSON.parse(normalized) as { insights?: unknown };
      if (Array.isArray(parsed.insights)) {
        const insights: string[] = this.cleanInsights(parsed.insights);
        if (insights.length > 0) {
          return insights;
        }
      }
    } catch {
      // Fall through to text splitting.
    }

    const lines = normalized
      .split(/\r?\n/)
      .map((line) => this.cleanInsightLine(line))
      .filter(Boolean)
      .slice(0, 5);
    return lines.length > 0
      ? lines
      : ["Review weekly money and call slow payers first."];
  }

  private cleanInsights(value?: unknown): string[] {
    if (!Array.isArray(value)) {
      return [];
    }

    const textItems = value
      .filter((item): item is string => typeof item === "string")
      .map((item) => item.trim())
      .filter(Boolean);

    if (
      textItems.some((item) => {
        return (
          item.startsWith("```") ||
          item === "{" ||
          item === "}" ||
          item.includes('"insights"')
        );
      })
    ) {
      return this.parseInsights(textItems.join("\n"));
    }

    return textItems
      .map((item) => this.cleanInsightLine(item))
      .filter(Boolean)
      .slice(0, 5);
  }

  private stripCodeFence(text: string) {
    return text
      .replace(/^```(?:json)?\s*/i, "")
      .replace(/\s*```$/i, "")
      .trim();
  }

  private cleanInsightLine(line: string) {
    const cleaned = line
      .replace(/^[-*\d.\s]+/, "")
      .replace(/^"+/, "")
      .replace(/",?$/, "")
      .replace(/^'+/, "")
      .replace(/',?$/, "")
      .trim();

    if (
      !cleaned ||
      cleaned === "{" ||
      cleaned === "}" ||
      cleaned === "[" ||
      cleaned === "]" ||
      cleaned.startsWith("```") ||
      cleaned.includes('"insights"')
    ) {
      return "";
    }

    return cleaned;
  }

  private todayFallbackText(today: {
    pendingCollection: string;
    callsDue: number;
    deliveriesDue: number;
    overdueCount: number;
  }) {
    return `${today.callsDue} calls and ${today.deliveriesDue} deliveries need attention. Pending collection is ₹${today.pendingCollection}.`;
  }

  private weeklyFallbackInsights(
    weekly: {
      revenue: string;
      grossProfitEstimate: string;
      businessExpenses: string;
    },
    people: { slowPayers: Array<{ name: string; avgDelayDays: number }> },
  ) {
    const insights = [
      `Revenue this week is ₹${weekly.revenue}; estimated profit is ₹${weekly.grossProfitEstimate}.`,
      `Business expenses are ₹${weekly.businessExpenses}; check transport and labour if this feels high.`,
    ];
    const slowPayer = people.slowPayers[0];
    if (slowPayer) {
      insights.push(
        `${slowPayer.name} is the slowest payer at ${slowPayer.avgDelayDays} days average delay.`,
      );
    }
    return insights;
  }

  private cacheKey(
    type: string,
    userId: string,
    date: string,
    provider: string,
    model: string,
  ) {
    return `ai:summary:${type}:${userId}:${date}:${provider}:${model}`;
  }

  private redisUrl() {
    return this.configService.get<string>("REDIS_URL")?.trim();
  }

  private bullConnectionOptions() {
    const url = new URL(this.redisUrl()!);
    return {
      host: url.hostname,
      port: Number(url.port || 6379),
      username: url.username || undefined,
      password: url.password || undefined,
      db: Number(url.pathname.replace("/", "") || 0),
      maxRetriesPerRequest: null,
    };
  }

  private dateOnly(date: Date) {
    return date.toISOString().slice(0, 10);
  }
}
