import {
  BadRequestException,
  NotFoundException,
  UnauthorizedException,
} from "@nestjs/common";
import {
  DealStatus,
  DealType,
  PartyType,
  Prisma,
  Role,
  TrustTag,
} from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { DealsService } from "./deals.service";

describe("DealsService", () => {
  let service: DealsService;
  let prisma: {
    deal: {
      findMany: jest.Mock;
      findUnique: jest.Mock;
      findFirst: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
    };
    party: {
      findFirst: jest.Mock;
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
      deal: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      party: {
        findFirst: jest.fn().mockResolvedValue(party()),
      },
    };

    service = new DealsService(prisma as unknown as PrismaService);
  });

  it("creates a bucket-wise deal scoped to the current user", async () => {
    prisma.deal.findUnique.mockResolvedValueOnce(null);
    prisma.deal.create.mockImplementation(async ({ data }) =>
      deal({
        ...data,
        party: party(),
        items: dealItemsFromCreate(data.items.create),
      }),
    );

    const result = await service.create(user, createDto());

    expect(prisma.party.findFirst).toHaveBeenCalledWith({
      where: {
        id: "a227f4ef-f302-41a8-9139-4803f94cda3b",
        userId: "user-1",
        deletedAt: null,
      },
    });
    expect(prisma.deal.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        id: "e7c33c2a-ef5d-48a7-989f-7c321c6171cb",
        userId: "user-1",
        partyId: "a227f4ef-f302-41a8-9139-4803f94cda3b",
        cashewGrade: "W320",
        quantityKg: new Prisma.Decimal(0),
        ratePerKg: new Prisma.Decimal(0),
        totalAmount: new Prisma.Decimal("39000.00"),
        paidAmount: new Prisma.Decimal("5000.00"),
        status: DealStatus.CONFIRMED,
        syncId: "sync-1",
        items: {
          create: [
            expect.objectContaining({
              id: "7c0e6b7f-6a90-402d-93fc-a52491cbffce",
              grade: "W320",
              quantityText: "10 balti",
              rateText: "780 per balti",
              totalAmount: new Prisma.Decimal("39000.00"),
              sortOrder: 0,
            }),
          ],
        },
      }),
      include: expect.any(Object),
    });
    expect(result).toMatchObject({
      id: "e7c33c2a-ef5d-48a7-989f-7c321c6171cb",
      totalAmount: "39000.00",
      paidAmount: "5000.00",
      party: { name: "Amit Verma" },
      items: [
        {
          grade: "W320",
          quantityText: "10 balti",
          rateText: "780 per balti",
          totalAmount: "39000.00",
        },
      ],
    });
  });

  it("returns existing same-user deal when syncId is duplicated", async () => {
    prisma.deal.findUnique.mockResolvedValueOnce(deal({ syncId: "sync-1" }));

    const result = await service.create(user, createDto({ syncId: "sync-1" }));

    expect(prisma.deal.create).not.toHaveBeenCalled();
    expect(result).toMatchObject({ syncId: "sync-1" });
  });

  it("rejects duplicate syncId owned by another user", async () => {
    prisma.deal.findUnique.mockResolvedValueOnce(
      deal({ userId: "user-2", syncId: "sync-1" }),
    );

    await expect(
      service.create(user, createDto({ syncId: "sync-1" })),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it("lists active deals with filters scoped to user", async () => {
    prisma.deal.findMany.mockResolvedValueOnce([deal()]);

    await service.list(user, {
      status: DealStatus.CONFIRMED,
      partyId: "a227f4ef-f302-41a8-9139-4803f94cda3b",
      grade: "w320",
      from: "2026-06-01T00:00:00.000Z",
      to: "2026-06-06T00:00:00.000Z",
    });

    expect(prisma.deal.findMany).toHaveBeenCalledWith({
      where: {
        userId: "user-1",
        deletedAt: null,
        status: DealStatus.CONFIRMED,
        partyId: "a227f4ef-f302-41a8-9139-4803f94cda3b",
        OR: [
          { cashewGrade: { contains: "w320", mode: "insensitive" } },
          {
            items: {
              some: {
                grade: { contains: "w320", mode: "insensitive" },
              },
            },
          },
        ],
        createdAt: {
          gte: new Date("2026-06-01T00:00:00.000Z"),
          lte: new Date("2026-06-06T00:00:00.000Z"),
        },
      },
      include: expect.any(Object),
      orderBy: [{ updatedAt: "desc" }, { createdAt: "desc" }],
    });
  });

  it("updates line items and manual totals", async () => {
    prisma.deal.findFirst.mockResolvedValueOnce(deal());
    prisma.deal.update.mockImplementation(async ({ data }) =>
      deal({
        ...data,
        party: party(),
        items: dealItemsFromCreate(data.items.create),
      }),
    );

    const result = await service.update(user, "deal-1", {
      items: [
        {
          id: "72c8a431-daae-4aef-9dfd-0ea2ff0dabd2",
          grade: "W240",
          quantityText: "5 balti",
          totalAmount: "18000.00",
        },
      ],
      totalAmount: "18000.00",
      paidAmount: "10000.00",
    });

    expect(prisma.deal.update).toHaveBeenCalledWith({
      where: { id: "deal-1" },
      data: {
        cashewGrade: "W240",
        quantityKg: new Prisma.Decimal(0),
        ratePerKg: new Prisma.Decimal(0),
        items: {
          deleteMany: {},
          create: [
            expect.objectContaining({
              grade: "W240",
              quantityText: "5 balti",
              totalAmount: new Prisma.Decimal("18000.00"),
            }),
          ],
        },
        totalAmount: new Prisma.Decimal("18000.00"),
        paidAmount: new Prisma.Decimal("10000.00"),
      },
      include: expect.any(Object),
    });
    expect(result.totalAmount).toBe("18000.00");
    expect(result.items).toHaveLength(1);
  });

  it("allows same-status no-op", async () => {
    prisma.deal.findFirst.mockResolvedValueOnce(
      deal({ status: DealStatus.CONFIRMED }),
    );

    const result = await service.updateStatus(
      user,
      "deal-1",
      DealStatus.CONFIRMED,
    );

    expect(prisma.deal.update).not.toHaveBeenCalled();
    expect(result.status).toBe(DealStatus.CONFIRMED);
  });

  it("rejects invalid status transitions", async () => {
    prisma.deal.findFirst.mockResolvedValueOnce(
      deal({ status: DealStatus.QUOTED }),
    );

    await expect(
      service.updateStatus(user, "deal-1", DealStatus.DELIVERED),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it("rejects PAID status until paid amount covers total", async () => {
    prisma.deal.findFirst.mockResolvedValueOnce(
      deal({
        status: DealStatus.DELIVERED,
        paidAmount: new Prisma.Decimal("5000.00"),
        totalAmount: new Prisma.Decimal("39000.00"),
      }),
    );

    await expect(
      service.updateStatus(user, "deal-1", DealStatus.PAID),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it("soft deletes active deals", async () => {
    prisma.deal.findFirst.mockResolvedValueOnce(deal());
    prisma.deal.update.mockImplementation(async ({ data }) =>
      deal({ deletedAt: data.deletedAt }),
    );

    const result = await service.remove(user, "deal-1");

    expect(prisma.deal.update).toHaveBeenCalledWith({
      where: { id: "deal-1" },
      data: { deletedAt: expect.any(Date) },
      include: expect.any(Object),
    });
    expect(result.deletedAt).toEqual(expect.any(String));
  });

  it("rejects missing or deleted deals", async () => {
    prisma.deal.findFirst.mockResolvedValueOnce(null);

    await expect(service.get(user, "missing-deal")).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });
});

function createDto(overrides: Record<string, unknown> = {}) {
  return {
    id: "e7c33c2a-ef5d-48a7-989f-7c321c6171cb",
    partyId: "a227f4ef-f302-41a8-9139-4803f94cda3b",
    type: DealType.SALE,
    items: [
      {
        id: "7c0e6b7f-6a90-402d-93fc-a52491cbffce",
        grade: " W320 ",
        quantityText: " 10 balti ",
        rateText: " 780 per balti ",
        totalAmount: "39000.00",
      },
    ],
    totalAmount: "39000.00",
    paidAmount: "5000.00",
    syncId: "sync-1",
    ...overrides,
  };
}

function party(overrides: Record<string, unknown> = {}) {
  const now = new Date("2026-06-06T10:00:00.000Z");
  return {
    id: "a227f4ef-f302-41a8-9139-4803f94cda3b",
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
  const now = new Date("2026-06-06T10:00:00.000Z");
  return {
    id: "deal-1",
    userId: "user-1",
    partyId: "a227f4ef-f302-41a8-9139-4803f94cda3b",
    type: DealType.SALE,
    cashewGrade: "W320",
    quantityKg: new Prisma.Decimal(0),
    ratePerKg: new Prisma.Decimal(0),
    totalAmount: new Prisma.Decimal("39000.00"),
    paidAmount: new Prisma.Decimal("5000.00"),
    status: DealStatus.CONFIRMED,
    deliveryDate: null,
    paymentDue: null,
    notes: null,
    syncId: "sync-1",
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    party: party(),
    items: dealItemsFromCreate(),
    ...overrides,
  };
}

function dealItemsFromCreate(rows: Record<string, unknown>[] = []) {
  const now = new Date("2026-06-06T10:00:00.000Z");
  const source =
    rows.length === 0
      ? [
          {
            id: "7c0e6b7f-6a90-402d-93fc-a52491cbffce",
            grade: "W320",
            quantityText: "10 balti",
            rateText: "780 per balti",
            totalAmount: new Prisma.Decimal("39000.00"),
            sortOrder: 0,
          },
        ]
      : rows;

  return source.map((row) => ({
    id: row.id,
    dealId: "deal-1",
    grade: row.grade,
    quantityText: row.quantityText,
    rateText: row.rateText ?? null,
    totalAmount: row.totalAmount,
    sortOrder: row.sortOrder ?? 0,
    createdAt: now,
    updatedAt: now,
  }));
}
