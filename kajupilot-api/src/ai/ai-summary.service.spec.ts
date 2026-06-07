import { Role } from "@prisma/client";
import { ConfigService } from "@nestjs/config";
import { InsightsService } from "../insights/insights.service";
import { PrismaService } from "../prisma/prisma.service";
import { AiRateLimitService } from "./ai-rate-limit.service";
import { AiSummaryService } from "./ai-summary.service";
import { AiService } from "./ai.service";

describe("AiSummaryService", () => {
  const user = {
    id: "user-1",
    role: Role.OWNER,
    name: "Owner",
    businessName: null,
  };

  it("parses fenced JSON weekly insights into clean bullets", async () => {
    const aiService = {
      getProviderSummary: () => ({
        active: { provider: "openai", model: "gpt-4o-mini" },
      }),
      generateText: jest.fn().mockResolvedValue({
        text: [
          "```json",
          "{",
          '  "insights": [',
          '    "Secure upfront payments before new dispatches."',
          "  ]",
          "}",
          "```",
        ].join("\n"),
        provider: "openai",
        model: "gpt-4o-mini",
      }),
    };
    const insightsService = {
      weekly: jest.fn().mockResolvedValue({
        revenue: "1000.00",
        grossProfitEstimate: "900.00",
        businessExpenses: "100.00",
      }),
      people: jest.fn().mockResolvedValue({ slowPayers: [] }),
    };
    const service = new AiSummaryService(
      aiService as unknown as AiService,
      insightsService as unknown as InsightsService,
      { user: { findMany: jest.fn() } } as unknown as PrismaService,
      new ConfigService({}),
    );

    const result = await service.weeklyInsights(user, "2026-06-07", true);

    expect(result.insights).toEqual([
      "Secure upfront payments before new dispatches.",
    ]);
  });

  it("closes rate-limit Redis resources on destroy", async () => {
    const redis = { quit: jest.fn() };
    const service = new AiRateLimitService(new ConfigService({}));
    (
      service as unknown as {
        redis: { quit: jest.Mock };
      }
    ).redis = redis;

    await service.onModuleDestroy();

    expect(redis.quit).toHaveBeenCalledTimes(1);
  });
});
