import { DealType, PaymentType, Prisma, Role, TaskType } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { InsightsService } from "./insights.service";

describe("InsightsService", () => {
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

    const result = await service.today(
      {
        id: "user-1",
        role: Role.OWNER,
        name: "Owner",
        businessName: null,
      },
      "2026-06-07",
    );

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
});
