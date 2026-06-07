import { BadRequestException, HttpException } from "@nestjs/common";
import {
  DealType,
  ExpenseCategory,
  ExpenseScope,
  PartyType,
  PaymentType,
  TaskType,
} from "@prisma/client";
import { AiParserService } from "./ai-parser.service";

describe("AiParserService", () => {
  let service: AiParserService;
  let aiService: { generateText: jest.Mock };
  let rateLimit: { assertParseAllowed: jest.Mock };
  let prisma: any;
  let parties: { id: string; name: string; phone: string | null }[];
  let logs: Record<string, any>;
  let createdParties: unknown[];
  let createdTasks: unknown[];
  let createdDeals: unknown[];
  let createdPayments: unknown[];
  let createdExpenses: unknown[];

  const user = {
    id: "user-1",
    name: "Owner",
    businessName: null,
    role: "OWNER" as const,
  };

  beforeEach(() => {
    parties = [{ id: "party-1", name: "Amit Verma", phone: "9876543210" }];
    logs = {};
    createdParties = [];
    createdTasks = [];
    createdDeals = [];
    createdPayments = [];
    createdExpenses = [];

    aiService = {
      generateText: jest.fn(),
    };
    rateLimit = {
      assertParseAllowed: jest.fn(),
    };
    prisma = {
      party: {
        findMany: jest.fn(async () => parties),
        findFirst: jest.fn(
          async ({ where }: any) =>
            parties.find((party) => party.id === where.id) ?? null,
        ),
      },
      aiParseLog: {
        create: jest.fn(async ({ data }: any) => {
          const id = `log-${Object.keys(logs).length + 1}`;
          logs[id] = { id, ...data, confirmed: false, confirmedJson: null };
          return logs[id];
        }),
        findFirst: jest.fn(async ({ where }: any) => logs[where.id] ?? null),
        update: jest.fn(async ({ where, data }: any) => {
          logs[where.id] = { ...logs[where.id], ...data };
          return logs[where.id];
        }),
      },
    };

    service = new AiParserService(
      aiService as any,
      rateLimit as any,
      prisma,
      {
        create: jest.fn(async (_user, dto) => {
          const party = {
            id: dto.id,
            userId: _user.id,
            name: dto.name,
            phone: null,
            type: dto.type,
            trustTag: dto.trustTag,
            syncId: dto.syncId,
          };
          parties.push({ id: party.id, name: party.name, phone: null });
          createdParties.push(party);
          return party;
        }),
      } as any,
      {
        create: jest.fn(async (_user, dto) => {
          const deal = { id: dto.id, ...dto };
          createdDeals.push(deal);
          return deal;
        }),
      } as any,
      {
        create: jest.fn(async (_user, dto) => {
          const payment = { id: dto.id, ...dto };
          createdPayments.push(payment);
          return payment;
        }),
      } as any,
      {
        create: jest.fn(async (_user, dto) => {
          const expense = { id: dto.id, ...dto };
          createdExpenses.push(expense);
          return expense;
        }),
      } as any,
      {
        create: jest.fn(async (_user, dto) => {
          const task = { id: dto.id, ...dto };
          createdTasks.push(task);
          return task;
        }),
      } as any,
    );
  });

  it("parses mixed trader input into normalized preview items", async () => {
    aiService.generateText.mockResolvedValueOnce({
      provider: "openai",
      model: "gpt-4o-mini",
      usage: { inputTokens: 10, outputTokens: 20, estimatedCostUsd: 0.01 },
      text: JSON.stringify({
        tasks: [
          {
            type: "CALL",
            personName: "Amit",
            title: "Call Amit for payment",
            amountPaise: 8000000,
            scheduledDate: "tomorrow",
            scheduledTime: "10:00",
          },
        ],
        deals: [
          {
            type: "SALE",
            personName: "Ramesh",
            items: [
              {
                grade: "W320",
                quantityText: "10 balti",
                rateText: "780 per balti",
                totalPaise: 780000,
              },
            ],
            totalPaise: 780000,
          },
        ],
        payments: [
          {
            type: "RECEIVED",
            personName: "Amit Verma",
            amountPaise: 5000000,
            paymentDate: "today",
          },
        ],
        expenses: [
          {
            scope: "PERSONAL",
            category: "OTHER",
            amountPaise: 120000,
            expenseDate: "today",
          },
        ],
      }),
    });

    const result = await service.parse(user, {
      text: "kal Amit ko 80k call, Ramesh W320 10 balti sale",
      localDate: "2026-06-07",
      timezone: "Asia/Kolkata",
    });

    expect(result.itemCount).toBe(4);
    expect(result.parsed.tasks[0].partyMatch?.status).toBe("matched");
    expect(result.parsed.deals[0].partyMatch?.status).toBe("new");
    expect(result.parsed.deals[0].warnings).toContain(
      "New contact will be created",
    );
    expect(logs[result.logId].provider).toBe("openai");
  });

  it("logs parse_failed when provider returns invalid JSON", async () => {
    aiService.generateText.mockResolvedValueOnce({
      provider: "groq",
      model: "llama",
      usage: { inputTokens: 1, outputTokens: 1, estimatedCostUsd: 0 },
      text: "not json",
    });

    await expect(
      service.parse(user, {
        text: "bad parse",
        localDate: "2026-06-07",
        timezone: "Asia/Kolkata",
      }),
    ).rejects.toBeInstanceOf(BadRequestException);

    expect(Object.values(logs)[0].error).toBeTruthy();
  });

  it("surfaces rate limit errors before calling AI", async () => {
    rateLimit.assertParseAllowed.mockRejectedValueOnce(
      new HttpException({ error: "rate_limited" }, 429),
    );

    await expect(
      service.parse(user, {
        text: "call Amit",
        localDate: "2026-06-07",
        timezone: "Asia/Kolkata",
      }),
    ).rejects.toBeInstanceOf(HttpException);
    expect(aiService.generateText).not.toHaveBeenCalled();
  });

  it("confirms all record types and creates one new party per name", async () => {
    logs["log-1"] = {
      id: "log-1",
      userId: user.id,
      confirmed: false,
      confirmedJson: null,
    };

    const result = await service.confirm(user, "log-1", {
      items: [
        {
          kind: "task",
          tempId: "task-1",
          partyName: "Amit Verma",
          type: TaskType.CALL,
          title: "Call Amit",
          scheduledAt: "2026-06-08T04:30:00.000Z",
        },
        {
          kind: "deal",
          tempId: "deal-1",
          partyName: "Ramesh",
          type: DealType.SALE,
          totalPaise: 780000,
          paidPaise: 0,
          items: [
            {
              grade: "W320",
              quantityText: "10 balti",
              totalPaise: 780000,
            },
          ],
        },
        {
          kind: "payment",
          tempId: "payment-1",
          partyName: "Ramesh",
          type: PaymentType.RECEIVED,
          amountPaise: 100000,
          paymentDate: "2026-06-07T06:30:00.000Z",
        },
        {
          kind: "expense",
          tempId: "expense-1",
          scope: ExpenseScope.PERSONAL,
          category: ExpenseCategory.OTHER,
          amountPaise: 50000,
          expenseDate: "2026-06-07T06:30:00.000Z",
        },
      ],
    });

    expect(result.created.parties).toHaveLength(1);
    expect(result.created.tasks).toHaveLength(1);
    expect(result.created.deals).toHaveLength(1);
    expect(result.created.payments).toHaveLength(1);
    expect(result.created.expenses).toHaveLength(1);
    expect(createdParties).toHaveLength(1);
    expect((createdParties[0] as any).type).toBe(PartyType.CUSTOMER);
  });

  it("returns stored created result when confirm is retried", async () => {
    logs["log-1"] = {
      id: "log-1",
      userId: user.id,
      confirmed: true,
      confirmedJson: { created: { tasks: [{ id: "task-1" }] } },
    };

    await expect(
      service.confirm(user, "log-1", { items: [] }),
    ).resolves.toEqual({ created: { tasks: [{ id: "task-1" }] } });
  });

  it("rejects confirm while any item still needs review", async () => {
    logs["log-1"] = {
      id: "log-1",
      userId: user.id,
      confirmed: false,
      confirmedJson: null,
    };

    await expect(
      service.confirm(user, "log-1", {
        items: [{ kind: "task", needsReview: true }],
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it("rejects ambiguous fuzzy party matches during confirm", async () => {
    parties = [
      { id: "party-1", name: "Amit Verma", phone: null },
      { id: "party-2", name: "Amit Shah", phone: null },
    ];
    logs["log-1"] = {
      id: "log-1",
      userId: user.id,
      confirmed: false,
      confirmedJson: null,
    };

    await expect(
      service.confirm(user, "log-1", {
        items: [
          {
            kind: "task",
            tempId: "task-1",
            partyName: "Amit",
            type: TaskType.CALL,
            title: "Call Amit",
            scheduledAt: "2026-06-08T04:30:00.000Z",
          },
        ],
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
