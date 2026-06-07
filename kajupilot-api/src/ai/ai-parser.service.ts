import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import {
  DealStatus,
  DealType,
  ExpenseCategory,
  ExpenseScope,
  PartyType,
  PaymentType,
  Prisma,
  TaskType,
  TrustTag,
} from "@prisma/client";
import { createHash, randomUUID } from "crypto";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { DealsService } from "../deals/deals.service";
import { ExpensesService } from "../expenses/expenses.service";
import { PartiesService } from "../parties/parties.service";
import { PaymentsService } from "../payments/payments.service";
import { PrismaService } from "../prisma/prisma.service";
import { TasksService } from "../tasks/tasks.service";
import { AiService } from "./ai.service";
import {
  AiConfirmCreated,
  AiConfirmResponse,
  AiParseResponse,
  ParsedAiItem,
  ParsedAiPayload,
  ParsedDealItem,
  ParsedExpenseItem,
  ParsedItemKind,
  ParsedPartyMatch,
  ParsedPaymentItem,
  ParsedTaskItem,
} from "./ai-parser.types";
import { AiRateLimitService } from "./ai-rate-limit.service";
import {
  ConfirmAiParseDto,
  ConfirmParsedItemDto,
} from "./dto/confirm-ai-parse.dto";
import { ParseAiDto } from "./dto/parse-ai.dto";
import { buildParserSystemPrompt } from "./prompts/parser.prompt";

type RawRecord = Record<string, unknown>;

@Injectable()
export class AiParserService {
  constructor(
    private readonly aiService: AiService,
    private readonly rateLimit: AiRateLimitService,
    private readonly prisma: PrismaService,
    private readonly partiesService: PartiesService,
    private readonly dealsService: DealsService,
    private readonly paymentsService: PaymentsService,
    private readonly expensesService: ExpensesService,
    private readonly tasksService: TasksService,
  ) {}

  async parse(
    user: AuthenticatedUser,
    dto: ParseAiDto,
  ): Promise<AiParseResponse> {
    const rawInput = dto.text.trim();
    if (!rawInput) {
      throw new BadRequestException({
        error: "parse_failed",
        message: "Text is required",
      });
    }

    await this.rateLimit.assertParseAllowed(user.id);

    const timezone = dto.timezone?.trim() || "Asia/Kolkata";
    const result = await this.aiService.generateText({
      systemPrompt: buildParserSystemPrompt({
        localDate: dto.localDate,
        timezone,
      }),
      prompt: rawInput,
    });

    try {
      const rawJson = this.parseProviderJson(result.text);
      const parsed = await this.normalizePayload(user.id, rawJson, {
        localDate: dto.localDate,
        timezone,
      });

      const log = await this.prisma.aiParseLog.create({
        data: {
          userId: user.id,
          rawInput,
          parsedJson: parsed as unknown as Prisma.InputJsonValue,
          provider: result.provider,
          model: result.model,
          usageJson: result.usage as unknown as Prisma.InputJsonValue,
        },
      });

      return {
        logId: log.id,
        provider: result.provider,
        model: result.model,
        usage: result.usage,
        parsed,
        itemCount: this.flatten(parsed).length,
        needsReviewCount: this.flatten(parsed).filter(
          (item) => item.needsReview,
        ).length,
      };
    } catch (error) {
      await this.prisma.aiParseLog.create({
        data: {
          userId: user.id,
          rawInput,
          parsedJson: this.emptyPayload() as unknown as Prisma.InputJsonValue,
          provider: result.provider,
          model: result.model,
          usageJson: result.usage as unknown as Prisma.InputJsonValue,
          error: error instanceof Error ? error.message : "parse_failed",
        },
      });

      throw new BadRequestException({
        error: "parse_failed",
        message: "AI response could not be parsed safely",
      });
    }
  }

  async confirm(
    user: AuthenticatedUser,
    logId: string,
    dto: ConfirmAiParseDto,
  ): Promise<AiConfirmResponse> {
    const log = await this.prisma.aiParseLog.findFirst({
      where: { id: logId, userId: user.id },
    });

    if (!log) {
      throw new NotFoundException("AI parse log not found");
    }

    if (log.confirmed && log.confirmedJson) {
      return log.confirmedJson as unknown as AiConfirmResponse;
    }

    const items = dto.items ?? [];
    if (items.some((item) => item.needsReview)) {
      throw new BadRequestException({
        error: "needs_review",
        message: "Resolve AI preview warnings before confirming",
      });
    }

    const inferredTypes = this.inferPartyTypes(items);
    const partyCache = new Map<string, string>();
    const created: AiConfirmCreated = {
      parties: [],
      tasks: [],
      deals: [],
      payments: [],
      expenses: [],
    };

    for (const item of items) {
      if (item.kind === "task") {
        const partyId = await this.resolvePartyForConfirm(
          user,
          logId,
          item,
          inferredTypes,
          partyCache,
          this.defaultPartyTypeForTask(item.type),
          created,
        );
        const task = await this.tasksService.create(user, {
          id: randomUUID(),
          partyId,
          type: this.enumValue(TaskType, item.type, TaskType.OTHER),
          title: this.requiredText(item.title, "Task title is required"),
          notes: this.cleanNullable(item.notes),
          scheduledAt: this.requiredText(
            item.scheduledAt,
            "Task schedule is required",
          ),
          priority: item.priority ?? 0,
          syncId: this.syncId(logId, item, "task"),
        });
        created.tasks.push(task);
        continue;
      }

      if (item.kind === "deal") {
        const partyId = await this.resolvePartyForConfirm(
          user,
          logId,
          item,
          inferredTypes,
          partyCache,
          this.defaultPartyTypeForDeal(item.type),
          created,
        );
        const dealItems = item.items ?? [];
        if (dealItems.length === 0) {
          throw new BadRequestException("Deal item is required");
        }
        const totalPaise =
          item.totalPaise ??
          dealItems.reduce((sum, row) => sum + row.totalPaise, 0);
        const deal = await this.dealsService.create(user, {
          id: randomUUID(),
          partyId: this.requiredText(partyId, "Deal party is required"),
          type: this.enumValue(DealType, item.type, DealType.SALE),
          items: dealItems.map((row) => ({
            id: randomUUID(),
            grade: this.requiredText(row.grade, "Deal grade is required"),
            quantityText: this.requiredText(
              row.quantityText,
              "Deal quantity is required",
            ),
            rateText: this.cleanNullable(row.rateText),
            totalAmount: this.paiseToDecimal(row.totalPaise),
          })),
          totalAmount: this.paiseToDecimal(totalPaise),
          paidAmount: this.paiseToDecimal(item.paidPaise ?? 0),
          deliveryDate: this.cleanNullable(item.deliveryDate),
          paymentDue: this.cleanNullable(item.paymentDue),
          notes: this.cleanNullable(item.notes),
          status: DealStatus.CONFIRMED,
          syncId: this.syncId(logId, item, "deal"),
        });
        created.deals.push(deal);
        continue;
      }

      if (item.kind === "payment") {
        const partyId = await this.resolvePartyForConfirm(
          user,
          logId,
          item,
          inferredTypes,
          partyCache,
          this.defaultPartyTypeForPayment(item.type),
          created,
        );
        const payment = await this.paymentsService.create(user, {
          id: randomUUID(),
          partyId: this.requiredText(partyId, "Payment party is required"),
          type: this.enumValue(PaymentType, item.type, PaymentType.RECEIVED),
          amount: this.paiseToDecimal(
            this.requiredNumber(item.amountPaise, "Payment amount is required"),
          ),
          method: this.cleanNullable(item.method),
          notes: this.cleanNullable(item.notes),
          paymentDate:
            this.cleanNullable(item.paymentDate) ?? new Date().toISOString(),
          syncId: this.syncId(logId, item, "payment"),
        });
        created.payments.push(payment);
        continue;
      }

      if (item.kind === "expense") {
        const expense = await this.expensesService.create(user, {
          id: randomUUID(),
          category: this.enumValue(
            ExpenseCategory,
            item.category,
            ExpenseCategory.OTHER,
          ),
          scope: this.enumValue(
            ExpenseScope,
            item.scope,
            ExpenseScope.BUSINESS,
          ),
          amount: this.paiseToDecimal(
            this.requiredNumber(item.amountPaise, "Expense amount is required"),
          ),
          notes: this.cleanNullable(item.notes),
          expenseDate:
            this.cleanNullable(item.expenseDate) ?? new Date().toISOString(),
          syncId: this.syncId(logId, item, "expense"),
        });
        created.expenses.push(expense);
      }
    }

    const response = { created };
    await this.prisma.aiParseLog.update({
      where: { id: log.id },
      data: {
        confirmed: true,
        confirmedAt: new Date(),
        confirmedJson: response as unknown as Prisma.InputJsonValue,
      },
    });

    return response;
  }

  private async normalizePayload(
    userId: string,
    rawJson: unknown,
    context: { localDate: string; timezone: string },
  ): Promise<ParsedAiPayload> {
    const data = this.asRecord(rawJson);
    const tasks = await Promise.all(
      this.asArray(data.tasks).map((raw, index) =>
        this.normalizeTask(userId, raw, index, context),
      ),
    );
    const deals = await Promise.all(
      this.asArray(data.deals).map((raw, index) =>
        this.normalizeDeal(userId, raw, index, context),
      ),
    );
    const payments = await Promise.all(
      this.asArray(data.payments).map((raw, index) =>
        this.normalizePayment(userId, raw, index, context),
      ),
    );
    const expenses = this.asArray(data.expenses).map((raw, index) =>
      this.normalizeExpense(raw, index, context),
    );

    return { tasks, deals, payments, expenses };
  }

  private async normalizeTask(
    userId: string,
    raw: unknown,
    index: number,
    context: { localDate: string; timezone: string },
  ): Promise<ParsedTaskItem> {
    const data = this.asRecord(raw);
    const warnings = this.stringArray(data.warnings);
    const partyName = this.stringOrNull(data.personName ?? data.partyName);
    const scheduledAt = this.resolveDateTime(
      data.scheduledDate ?? data.scheduled ?? data.date,
      data.scheduledTime ?? data.time,
      context,
      { defaultTime: "10:00" },
    );
    const item: ParsedTaskItem = {
      kind: "task",
      tempId: `task-${index + 1}`,
      partyName,
      type: this.enumValue(TaskType, data.type, TaskType.OTHER),
      title:
        this.stringOrNull(data.title ?? data.purpose) ??
        this.defaultTaskTitle(data.type, partyName),
      notes: this.stringOrNull(data.notes),
      scheduledAt,
      priority: this.clampInt(data.priority, 0, 5, 0),
      amountPaise: this.moneyToPaise(data.amountPaise, data.amount) || null,
      needsReview: false,
      warnings,
    };

    item.partyMatch = await this.matchPartyForPreview(userId, partyName);
    this.reviewParty(item, false);
    if (!item.scheduledAt) {
      item.warnings.push("Task date/time needs review");
    }
    if (!item.title.trim()) {
      item.warnings.push("Task title is missing");
    }
    item.needsReview = this.hasBlockingWarnings(item.warnings);
    return item;
  }

  private async normalizeDeal(
    userId: string,
    raw: unknown,
    index: number,
    context: { localDate: string; timezone: string },
  ): Promise<ParsedDealItem> {
    const data = this.asRecord(raw);
    const warnings = this.stringArray(data.warnings);
    const partyName = this.stringOrNull(data.personName ?? data.partyName);
    const rows = this.asArray(data.items).map((row) => {
      const item = this.asRecord(row);
      return {
        grade: this.stringOrNull(item.grade ?? item.cashewGrade) ?? "",
        quantityText:
          this.stringOrNull(item.quantityText ?? item.quantity) ?? "",
        rateText: this.stringOrNull(item.rateText ?? item.rate),
        totalPaise: this.moneyToPaise(item.totalPaise, item.totalAmount),
      };
    });
    const totalPaise =
      this.moneyToPaise(data.totalPaise, data.totalAmount) ||
      rows.reduce((sum, row) => sum + row.totalPaise, 0);
    const item: ParsedDealItem = {
      kind: "deal",
      tempId: `deal-${index + 1}`,
      partyName,
      type: this.enumValue(DealType, data.type, DealType.SALE),
      items: rows,
      totalPaise,
      paidPaise: this.moneyToPaise(data.paidPaise, data.paidAmount),
      status: DealStatus.CONFIRMED,
      deliveryDate: this.resolveDateOnly(data.deliveryDate, context),
      paymentDue: this.resolveDateOnly(data.paymentDue, context),
      notes: this.stringOrNull(data.notes),
      needsReview: false,
      warnings,
    };

    item.partyMatch = await this.matchPartyForPreview(userId, partyName);
    this.reviewParty(item, true);
    if (item.items.length === 0) {
      item.warnings.push("Deal item is missing");
    }
    for (const row of item.items) {
      if (!row.grade.trim()) item.warnings.push("Deal grade is missing");
      if (!row.quantityText.trim())
        item.warnings.push("Deal quantity is missing");
      if (row.totalPaise <= 0)
        item.warnings.push("Deal item total needs review");
    }
    if (item.totalPaise <= 0) item.warnings.push("Deal total needs review");
    if (item.paidPaise > item.totalPaise) {
      item.warnings.push("Paid amount exceeds deal total");
    }
    item.needsReview = this.hasBlockingWarnings(item.warnings);
    return item;
  }

  private async normalizePayment(
    userId: string,
    raw: unknown,
    index: number,
    context: { localDate: string; timezone: string },
  ): Promise<ParsedPaymentItem> {
    const data = this.asRecord(raw);
    const warnings = this.stringArray(data.warnings);
    const partyName = this.stringOrNull(data.personName ?? data.partyName);
    const item: ParsedPaymentItem = {
      kind: "payment",
      tempId: `payment-${index + 1}`,
      partyName,
      type: this.enumValue(PaymentType, data.type, PaymentType.RECEIVED),
      amountPaise: this.moneyToPaise(data.amountPaise, data.amount),
      method: this.stringOrNull(data.method),
      paymentDate:
        this.resolveDateOnly(data.paymentDate ?? data.date, context) ??
        this.resolveDateOnly("today", context),
      notes: this.stringOrNull(data.notes),
      needsReview: false,
      warnings,
    };

    item.partyMatch = await this.matchPartyForPreview(userId, partyName);
    this.reviewParty(item, true);
    if (item.amountPaise <= 0) item.warnings.push("Payment amount is missing");
    item.needsReview = this.hasBlockingWarnings(item.warnings);
    return item;
  }

  private normalizeExpense(
    raw: unknown,
    index: number,
    context: { localDate: string; timezone: string },
  ): ParsedExpenseItem {
    const data = this.asRecord(raw);
    const warnings = this.stringArray(data.warnings);
    const item: ParsedExpenseItem = {
      kind: "expense",
      tempId: `expense-${index + 1}`,
      scope: this.enumValue(ExpenseScope, data.scope, ExpenseScope.BUSINESS),
      category: this.enumValue(
        ExpenseCategory,
        data.category,
        ExpenseCategory.OTHER,
      ),
      amountPaise: this.moneyToPaise(data.amountPaise, data.amount),
      expenseDate:
        this.resolveDateOnly(data.expenseDate ?? data.date, context) ??
        this.resolveDateOnly("today", context),
      notes: this.stringOrNull(data.notes),
      needsReview: false,
      warnings,
    };

    if (item.amountPaise <= 0) item.warnings.push("Expense amount is missing");
    item.needsReview = this.hasBlockingWarnings(item.warnings);
    return item;
  }

  private async matchPartyForPreview(
    userId: string,
    partyName: string | null | undefined,
  ): Promise<ParsedPartyMatch> {
    const name = partyName?.trim();
    if (!name) {
      return { status: "missing" };
    }

    const match = await this.matchParty(userId, name);
    if (match.status === "matched") {
      return {
        status: "matched",
        partyId: match.party.id,
        name: match.party.name,
      };
    }
    if (match.status === "ambiguous") {
      return {
        status: "ambiguous",
        candidates: match.candidates.map((party) => ({
          id: party.id,
          name: party.name,
          phone: party.phone,
        })),
      };
    }
    return { status: "new", name };
  }

  private reviewParty(item: ParsedAiItem, required: boolean) {
    if (item.partyMatch?.status === "matched") {
      item.partyId = item.partyMatch.partyId;
      return;
    }
    if (item.partyMatch?.status === "ambiguous") {
      item.warnings.push("Choose the matching person");
      return;
    }
    if (required && item.partyMatch?.status === "missing") {
      item.warnings.push("Person is missing");
      return;
    }
    if (item.partyMatch?.status === "new") {
      item.warnings.push("New contact will be created");
    }
  }

  private async resolvePartyForConfirm(
    user: AuthenticatedUser,
    logId: string,
    item: ConfirmParsedItemDto,
    inferredTypes: Map<string, PartyType>,
    partyCache: Map<string, string>,
    fallbackType: PartyType,
    created: AiConfirmCreated,
  ): Promise<string | null> {
    if (item.partyId) {
      const existing = await this.prisma.party.findFirst({
        where: { id: item.partyId, userId: user.id, deletedAt: null },
      });
      if (!existing) throw new BadRequestException("Selected party not found");
      return existing.id;
    }

    const name = item.partyName?.trim();
    if (!name) {
      return null;
    }

    const key = this.normalizedName(name);
    if (partyCache.has(key)) {
      return partyCache.get(key)!;
    }

    const match = await this.matchParty(user.id, name);
    if (match.status === "matched") {
      partyCache.set(key, match.party.id);
      return match.party.id;
    }
    if (match.status === "ambiguous") {
      throw new BadRequestException(
        "Choose the matching person before confirm",
      );
    }

    const type = inferredTypes.get(key) ?? fallbackType;
    const party = await this.partiesService.create(user, {
      id: randomUUID(),
      name,
      type,
      trustTag: TrustTag.NEW,
      syncId: `ai-${logId}-party-${this.shortHash(key)}`,
    });
    const partyId = this.asRecord(party).id as string;
    partyCache.set(key, partyId);
    created.parties.push(party);
    return partyId;
  }

  private async matchParty(userId: string, name: string) {
    const parties = await this.prisma.party.findMany({
      where: { userId, deletedAt: null },
      select: { id: true, name: true, phone: true },
    });
    const normalized = this.normalizedName(name);

    const exact = parties.find(
      (party) => this.normalizedName(party.name) === normalized,
    );
    if (exact) return { status: "matched" as const, party: exact };

    const prefixMatches = parties.filter((party) => {
      const candidate = this.normalizedName(party.name);
      const firstName = candidate.split(" ")[0] ?? candidate;
      return candidate.startsWith(normalized) || normalized === firstName;
    });
    if (prefixMatches.length === 1) {
      return { status: "matched" as const, party: prefixMatches[0] };
    }
    if (prefixMatches.length > 1) {
      return { status: "ambiguous" as const, candidates: prefixMatches };
    }

    const fuzzyMatches = parties.filter(
      (party) =>
        this.levenshtein(this.normalizedName(party.name), normalized) <= 2,
    );
    if (fuzzyMatches.length === 1) {
      return { status: "matched" as const, party: fuzzyMatches[0] };
    }
    if (fuzzyMatches.length > 1) {
      return { status: "ambiguous" as const, candidates: fuzzyMatches };
    }

    return { status: "new" as const };
  }

  private inferPartyTypes(items: ConfirmParsedItemDto[]) {
    const map = new Map<string, PartyType>();
    for (const item of items) {
      const name = item.partyName?.trim();
      if (!name) continue;
      const key = this.normalizedName(name);
      const next =
        item.kind === "deal"
          ? this.defaultPartyTypeForDeal(item.type)
          : item.kind === "payment"
            ? this.defaultPartyTypeForPayment(item.type)
            : item.kind === "task"
              ? this.defaultPartyTypeForTask(item.type)
              : PartyType.CUSTOMER;
      map.set(key, this.mergePartyType(map.get(key), next));
    }
    return map;
  }

  private defaultPartyTypeForDeal(value?: string) {
    return value === DealType.PURCHASE
      ? PartyType.SUPPLIER
      : PartyType.CUSTOMER;
  }

  private defaultPartyTypeForPayment(value?: string) {
    return value === PaymentType.PAID ? PartyType.SUPPLIER : PartyType.CUSTOMER;
  }

  private defaultPartyTypeForTask(value?: string) {
    return value === TaskType.DELIVERY || value === TaskType.PAYMENT_COLLECTION
      ? PartyType.CUSTOMER
      : PartyType.CUSTOMER;
  }

  private mergePartyType(current: PartyType | undefined, next: PartyType) {
    if (!current) return next;
    if (current === next) return current;
    return PartyType.BOTH;
  }

  private parseProviderJson(text: string) {
    const cleaned = text
      .trim()
      .replace(/^```(?:json)?/i, "")
      .replace(/```$/i, "");
    const start = cleaned.indexOf("{");
    const end = cleaned.lastIndexOf("}");
    if (start < 0 || end < start) {
      throw new Error("AI response did not contain JSON");
    }
    return JSON.parse(cleaned.slice(start, end + 1));
  }

  private resolveDateOnly(
    value: unknown,
    context: { localDate: string; timezone: string },
  ) {
    const date = this.resolveDateToken(value, context.localDate);
    if (!date) return null;
    return this.localIso(date, "12:00", context.timezone);
  }

  private resolveDateTime(
    dateValue: unknown,
    timeValue: unknown,
    context: { localDate: string; timezone: string },
    options: { defaultTime: string },
  ) {
    const date = this.resolveDateToken(dateValue, context.localDate);
    if (!date) return null;
    const time = this.resolveTimeToken(timeValue) ?? options.defaultTime;
    return this.localIso(date, time, context.timezone);
  }

  private resolveDateToken(value: unknown, localDate: string) {
    const raw = this.stringOrNull(value)?.toLowerCase();
    if (!raw || raw === "null") return null;
    if (raw === "today" || raw === "aaj") return localDate;
    if (raw === "tomorrow" || raw === "kal") return this.addDays(localDate, 1);
    if (/^\d{4}-\d{2}-\d{2}$/.test(raw)) return raw;
    return null;
  }

  private resolveTimeToken(value: unknown) {
    const raw = this.stringOrNull(value);
    if (!raw || raw.toLowerCase() === "null") return null;
    const match = raw.match(/^(\d{1,2}):(\d{2})$/);
    if (!match) return null;
    const hour = Number(match[1]);
    const minute = Number(match[2]);
    if (hour > 23 || minute > 59) return null;
    return `${hour.toString().padStart(2, "0")}:${minute
      .toString()
      .padStart(2, "0")}`;
  }

  private localIso(date: string, time: string, timezone: string) {
    const offset = /kolkata|calcutta|india/i.test(timezone) ? "+05:30" : "Z";
    return new Date(`${date}T${time}:00${offset}`).toISOString();
  }

  private addDays(date: string, days: number) {
    const value = new Date(`${date}T00:00:00.000Z`);
    value.setUTCDate(value.getUTCDate() + days);
    return value.toISOString().slice(0, 10);
  }

  private moneyToPaise(paiseValue: unknown, rupeeValue?: unknown) {
    if (paiseValue !== undefined && paiseValue !== null) {
      return Math.max(0, Math.round(Number(paiseValue) || 0));
    }
    if (rupeeValue === undefined || rupeeValue === null) return 0;
    if (typeof rupeeValue === "number")
      return Math.max(0, Math.round(rupeeValue * 100));

    const raw = String(rupeeValue)
      .trim()
      .toLowerCase()
      .replace(/[,₹rs\s]/g, "");
    const multiplier =
      raw.includes("lakh") || raw.includes("lac") || raw.endsWith("l")
        ? 100000
        : raw.endsWith("k")
          ? 1000
          : 1;
    const number = Number(raw.replace(/lakh|lac|[lk]/g, ""));
    return Number.isFinite(number)
      ? Math.max(0, Math.round(number * multiplier * 100))
      : 0;
  }

  private paiseToDecimal(paise: number) {
    return (paise / 100).toFixed(2);
  }

  private enumValue<T extends Record<string, string>>(
    enumObject: T,
    value: unknown,
    fallback: T[keyof T],
  ): T[keyof T] {
    const raw = this.stringOrNull(value)?.toUpperCase();
    const values = Object.values(enumObject) as T[keyof T][];
    return values.includes(raw as T[keyof T]) ? (raw as T[keyof T]) : fallback;
  }

  private defaultTaskTitle(value: unknown, partyName?: string | null) {
    const type = this.enumValue(TaskType, value, TaskType.OTHER);
    const name = partyName?.trim();
    if (type === TaskType.CALL) return name ? `Call ${name}` : "Call reminder";
    if (type === TaskType.PAYMENT_COLLECTION) {
      return name ? `Collect payment from ${name}` : "Collect payment";
    }
    if (type === TaskType.DELIVERY)
      return name ? `Delivery for ${name}` : "Delivery";
    return name ? `Follow up with ${name}` : "Reminder";
  }

  private syncId(
    logId: string,
    item: ConfirmParsedItemDto,
    kind: ParsedItemKind,
  ) {
    return `ai-${logId}-${kind}-${this.shortHash(item.tempId ?? JSON.stringify(item))}`;
  }

  private shortHash(value: string) {
    return createHash("sha1").update(value).digest("hex").slice(0, 16);
  }

  private normalizedName(value: string) {
    return value
      .toLowerCase()
      .replace(/[^a-z0-9 ]/g, "")
      .replace(/\s+/g, " ")
      .trim();
  }

  private levenshtein(a: string, b: string) {
    const matrix = Array.from({ length: a.length + 1 }, (_, row) =>
      Array.from({ length: b.length + 1 }, (_, column) =>
        row === 0 ? column : column === 0 ? row : 0,
      ),
    );
    for (let row = 1; row <= a.length; row += 1) {
      for (let column = 1; column <= b.length; column += 1) {
        const cost = a[row - 1] === b[column - 1] ? 0 : 1;
        matrix[row][column] = Math.min(
          matrix[row - 1][column] + 1,
          matrix[row][column - 1] + 1,
          matrix[row - 1][column - 1] + cost,
        );
      }
    }
    return matrix[a.length][b.length];
  }

  private flatten(payload: ParsedAiPayload) {
    return [
      ...payload.tasks,
      ...payload.deals,
      ...payload.payments,
      ...payload.expenses,
    ];
  }

  private hasBlockingWarnings(warnings: string[]) {
    return warnings.some(
      (warning) => warning !== "New contact will be created",
    );
  }

  private emptyPayload(): ParsedAiPayload {
    return { tasks: [], deals: [], payments: [], expenses: [] };
  }

  private asRecord(value: unknown): RawRecord {
    return value && typeof value === "object" && !Array.isArray(value)
      ? (value as RawRecord)
      : {};
  }

  private asArray(value: unknown): unknown[] {
    return Array.isArray(value) ? value : [];
  }

  private stringOrNull(value: unknown) {
    if (typeof value !== "string") return null;
    const trimmed = value.trim();
    return trimmed && trimmed.toLowerCase() !== "null" ? trimmed : null;
  }

  private stringArray(value: unknown) {
    return Array.isArray(value)
      ? value.map((item) => String(item).trim()).filter(Boolean)
      : [];
  }

  private cleanNullable(value?: string | null) {
    const trimmed = value?.trim();
    return trimmed ? trimmed : undefined;
  }

  private requiredText(value: unknown, message: string) {
    const text = this.stringOrNull(value);
    if (!text) throw new BadRequestException(message);
    return text;
  }

  private requiredNumber(value: unknown, message: string) {
    const number = Number(value);
    if (!Number.isFinite(number) || number <= 0) {
      throw new BadRequestException(message);
    }
    return Math.round(number);
  }

  private clampInt(value: unknown, min: number, max: number, fallback: number) {
    const number = Number(value);
    if (!Number.isFinite(number)) return fallback;
    return Math.max(min, Math.min(max, Math.round(number)));
  }
}
