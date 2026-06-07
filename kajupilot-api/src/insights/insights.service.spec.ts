import {
  DealType,
  ExpenseCategory,
  ExpenseScope,
  PartyType,
  PaymentType,
  Prisma,
  Role,
  TaskType,
  TrustTag,
} from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { InsightsService } from "./insights.service";

describe("InsightsService", () => {
  const user = {
    id: "user-1",
    role: Role.OWNER,
    name: "Owner",
    businessName: null,
  };

  it("returns today totals from deals, payments, and tasks", async () => {
    const prisma = {
      party: {
        findMany: jest.fn().mockResolvedValue([
          {
            deals: [
              {
                type: DealType.SALE,
                totalAmount: new Prisma.Decimal("1000.00"),
                paidAmount: new Prisma.Decimal("200.00"),
                paymentDue: new Date("2026-06-06T00:00:00.000Z"),
              },
            ],
            payments: [
              {
                type: PaymentType.RECEIVED,
                amount: new Prisma.Decimal("100.00"),
              },
            ],
          },
        ]),
      },
      task: {
        count: jest
          .fn()
          .mockResolvedValueOnce(2)
          .mockResolvedValueOnce(1)
          .mockResolvedValueOnce(3),
        findMany: jest.fn().mockResolvedValue([
          {
            id: "task-1",
            partyId: "party-1",
            title: "Call Amit",
            scheduledAt: new Date("2026-06-07T10:00:00.000Z"),
            priority: 2,
            party: { name: "Amit", phone: "98765" },
          },
        ]),
      },
    };
    const service = new InsightsService(prisma as unknown as PrismaService);

    const result = await service.today(user, "2026-06-07");

    expect(result).toMatchObject({
      pendingCollection: "700.00",
      callsDue: 2,
      deliveriesDue: 1,
      overdueCount: 4,
    });
    expect(result.topCallsToday[0]).toMatchObject({
      reason: "Call Amit",
    });
    expect(prisma.task.count).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ type: TaskType.CALL }),
      }),
    );
  });

  it("returns weekly revenue, expense, and top buyer totals", async () => {
    const prisma = {
      payment: {
        findMany: jest.fn().mockResolvedValue([
          {
            type: PaymentType.RECEIVED,
            amount: new Prisma.Decimal("5000.00"),
          },
          {
            type: PaymentType.PAID,
            amount: new Prisma.Decimal("700.00"),
          },
        ]),
      },
      expense: {
        findMany: jest.fn().mockResolvedValue([
          {
            category: ExpenseCategory.TRANSPORT,
            scope: ExpenseScope.BUSINESS,
            amount: new Prisma.Decimal("900.00"),
          },
          {
            category: ExpenseCategory.OTHER,
            scope: ExpenseScope.PERSONAL,
            amount: new Prisma.Decimal("250.00"),
          },
        ]),
      },
      deal: {
        count: jest.fn().mockResolvedValue(2),
      },
      party: {
        count: jest.fn().mockResolvedValue(1),
        findMany: jest.fn().mockResolvedValue([
          {
            id: "party-1",
            name: "Amit Verma",
            phone: "98765",
            type: PartyType.CUSTOMER,
            trustTag: TrustTag.RELIABLE,
            trustTagManualOverride: true,
            createdAt: new Date("2026-06-01T08:00:00.000Z"),
            updatedAt: new Date("2026-06-02T08:00:00.000Z"),
            deals: [
              {
                id: "deal-1",
                type: DealType.SALE,
                totalAmount: new Prisma.Decimal("4200.00"),
                paidAmount: new Prisma.Decimal("4200.00"),
                paymentDue: new Date("2026-06-03T00:00:00.000Z"),
                createdAt: new Date("2026-06-04T08:00:00.000Z"),
                updatedAt: new Date("2026-06-05T08:00:00.000Z"),
              },
            ],
            payments: [],
            callLogs: [],
          },
        ]),
      },
    };
    const service = new InsightsService(prisma as unknown as PrismaService);

    const result = await service.weekly(user, "2026-06-07");

    expect(result).toMatchObject({
      revenue: "5000.00",
      businessExpenses: "900.00",
      personalExpenses: "250.00",
      grossProfitEstimate: "4100.00",
      dealsClosedCount: 2,
      newPartiesCount: 1,
    });
    expect(result.topBuyers[0]).toMatchObject({
      partyId: "party-1",
      amount: "4200.00",
      dealCount: 1,
    });
    expect(result.expenseBreakdown.byCategory.TRANSPORT).toBe("900.00");
  });

  it("auto-tags only non-manual slow payers", async () => {
    const prisma = {
      party: {
        findMany: jest
          .fn()
          .mockResolvedValue([
            slowPayerParty("auto-party", false),
            slowPayerParty("manual-party", true),
          ]),
        updateMany: jest.fn().mockResolvedValue({ count: 1 }),
      },
    };
    const service = new InsightsService(prisma as unknown as PrismaService);

    const result = await service.people(user, "2026-06-07");

    expect(result.slowPayers).toHaveLength(2);
    expect(result.trustTagUpdates).toEqual([
      {
        partyId: "auto-party",
        name: "Auto Slow",
        previousTrustTag: TrustTag.NEW,
        trustTag: TrustTag.SLOW_PAYER,
        avgDelayDays: 14,
      },
    ]);
    expect(prisma.party.updateMany).toHaveBeenCalledWith({
      where: { id: "auto-party", userId: "user-1" },
      data: { trustTag: TrustTag.SLOW_PAYER },
    });
  });
});

function slowPayerParty(id: string, manualOverride: boolean) {
  return {
    id,
    name: manualOverride ? "Manual Slow" : "Auto Slow",
    phone: "98765",
    type: PartyType.CUSTOMER,
    trustTag: TrustTag.NEW,
    trustTagManualOverride: manualOverride,
    createdAt: new Date("2026-05-01T08:00:00.000Z"),
    updatedAt: new Date("2026-05-25T08:00:00.000Z"),
    deals: [
      {
        id: `${id}-deal`,
        type: DealType.SALE,
        totalAmount: new Prisma.Decimal("1000.00"),
        paidAmount: new Prisma.Decimal("0.00"),
        paymentDue: new Date("2026-05-25T00:00:00.000Z"),
        createdAt: new Date("2026-05-20T08:00:00.000Z"),
        updatedAt: new Date("2026-05-20T08:00:00.000Z"),
      },
    ],
    payments: [],
    callLogs: [],
  };
}
