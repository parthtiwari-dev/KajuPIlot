import { BadRequestException, UnauthorizedException } from "@nestjs/common";
import {
  DealType,
  PartyType,
  PaymentType,
  Prisma,
  Role,
  TrustTag,
} from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { PaymentsService } from "./payments.service";

describe("PaymentsService", () => {
  let service: PaymentsService;
  let prisma: {
    $transaction: jest.Mock;
    payment: {
      findMany: jest.Mock;
      findUnique: jest.Mock;
      findFirst: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
    };
    party: {
      findFirst: jest.Mock;
      findMany: jest.Mock;
    };
    deal: {
      findFirst: jest.Mock;
      update: jest.Mock;
    };
  };

  const user = {
    id: "user-1",
    role: Role.OWNER,
    name: "Owner",
    businessName: null,
  };

  beforeEach(() => {
    prisma = {
      $transaction: jest.fn((callback) => callback(prisma)),
      payment: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      party: {
        findFirst: jest.fn().mockResolvedValue(party()),
        findMany: jest.fn(),
      },
      deal: {
        findFirst: jest.fn().mockResolvedValue(deal()),
        update: jest.fn(),
      },
    };
    service = new PaymentsService(prisma as unknown as PrismaService);
  });

  it("creates a linked payment and updates the deal paid amount", async () => {
    prisma.payment.findUnique.mockResolvedValueOnce(null);
    prisma.payment.create.mockImplementation(async ({ data }) =>
      payment({
        ...data,
        party: party(),
        deal: deal({ paidAmount: new Prisma.Decimal("15000.00") }),
      }),
    );

    const result = await service.create(user, createDto());

    expect(prisma.deal.update).toHaveBeenCalledWith({
      where: { id: "deal-1" },
      data: { paidAmount: new Prisma.Decimal("15000.00") },
    });
    expect(prisma.payment.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        id: "payment-1",
        userId: "user-1",
        partyId: "party-1",
        dealId: "deal-1",
        type: PaymentType.RECEIVED,
        amount: new Prisma.Decimal("10000.00"),
        syncId: "sync-1",
      }),
      include: expect.any(Object),
    });
    expect(result).toMatchObject({
      id: "payment-1",
      amount: "10000.00",
      party: { name: "Amit Verma" },
      deal: { id: "deal-1", paidAmount: "15000.00" },
    });
  });

  it("returns existing same-user payment when syncId is duplicated", async () => {
    prisma.payment.findUnique.mockResolvedValueOnce(
      payment({ syncId: "sync-1" }),
    );

    const result = await service.create(user, createDto({ syncId: "sync-1" }));

    expect(prisma.payment.create).not.toHaveBeenCalled();
    expect(result.syncId).toBe("sync-1");
  });

  it("rejects duplicate syncId owned by another user", async () => {
    prisma.payment.findUnique.mockResolvedValueOnce(
      payment({ userId: "user-2", syncId: "sync-1" }),
    );

    await expect(
      service.create(user, createDto({ syncId: "sync-1" })),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it("rejects linked payments that exceed the deal total", async () => {
    prisma.payment.findUnique.mockResolvedValueOnce(null);
    prisma.deal.findFirst.mockResolvedValueOnce(
      deal({
        totalAmount: new Prisma.Decimal("39000.00"),
        paidAmount: new Prisma.Decimal("38000.00"),
      }),
    );

    await expect(
      service.create(user, createDto({ amount: "2000.00" })),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it("rejects the wrong payment type for a linked sale deal", async () => {
    prisma.payment.findUnique.mockResolvedValueOnce(null);

    await expect(
      service.create(user, createDto({ type: PaymentType.PAID })),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it("soft deletes linked payments and reverses deal paid amount", async () => {
    prisma.payment.findFirst.mockResolvedValueOnce(payment());
    prisma.deal.findFirst.mockResolvedValueOnce(
      deal({ paidAmount: new Prisma.Decimal("15000.00") }),
    );
    prisma.payment.update.mockImplementation(async ({ data }) =>
      payment({ deletedAt: data.deletedAt }),
    );

    const result = await service.remove(user, "payment-1");

    expect(prisma.deal.update).toHaveBeenCalledWith({
      where: { id: "deal-1" },
      data: { paidAmount: new Prisma.Decimal("5000.00") },
    });
    expect(result.deletedAt).toEqual(expect.any(String));
  });

  it("computes ledger from deals and party-level credits", async () => {
    prisma.party.findMany.mockResolvedValueOnce([
      {
        ...party(),
        deals: [
          deal({
            totalAmount: new Prisma.Decimal("39000.00"),
            paidAmount: new Prisma.Decimal("5000.00"),
          }),
        ],
        payments: [
          {
            type: PaymentType.RECEIVED,
            amount: new Prisma.Decimal("10000.00"),
            paymentDate: new Date("2026-06-07T00:00:00.000Z"),
          },
        ],
      },
    ]);

    await expect(service.ledger(user)).resolves.toMatchObject({
      totalReceivable: "24000.00",
      totalPayable: "0.00",
      net: "24000.00",
    });
  });
});

function createDto(overrides: Record<string, unknown> = {}) {
  return {
    id: "payment-1",
    partyId: "party-1",
    dealId: "deal-1",
    type: PaymentType.RECEIVED,
    amount: "10000.00",
    method: "Cash",
    paymentDate: "2026-06-07T00:00:00.000Z",
    notes: "Advance",
    syncId: "sync-1",
    ...overrides,
  };
}

function party(overrides: Record<string, unknown> = {}) {
  const now = new Date("2026-06-07T00:00:00.000Z");
  return {
    id: "party-1",
    userId: "user-1",
    name: "Amit Verma",
    phone: "98765",
    type: PartyType.CUSTOMER,
    trustTag: TrustTag.NEW,
    notes: null,
    syncId: "party-sync-1",
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    ...overrides,
  };
}

function deal(overrides: Record<string, unknown> = {}) {
  const now = new Date("2026-06-07T00:00:00.000Z");
  return {
    id: "deal-1",
    userId: "user-1",
    partyId: "party-1",
    type: DealType.SALE,
    cashewGrade: "W320",
    quantityKg: new Prisma.Decimal(0),
    ratePerKg: new Prisma.Decimal(0),
    totalAmount: new Prisma.Decimal("39000.00"),
    paidAmount: new Prisma.Decimal("5000.00"),
    status: "CONFIRMED",
    deliveryDate: null,
    paymentDue: null,
    notes: null,
    syncId: "deal-sync-1",
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    ...overrides,
  };
}

function payment(overrides: Record<string, unknown> = {}) {
  const now = new Date("2026-06-07T00:00:00.000Z");
  return {
    id: "payment-1",
    userId: "user-1",
    partyId: "party-1",
    dealId: "deal-1",
    type: PaymentType.RECEIVED,
    amount: new Prisma.Decimal("10000.00"),
    method: "Cash",
    notes: "Advance",
    paymentDate: now,
    syncId: "sync-1",
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    party: party(),
    deal: deal(),
    ...overrides,
  };
}
