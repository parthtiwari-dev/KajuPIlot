import { NotFoundException, UnauthorizedException } from "@nestjs/common";
import { DealType, PartyType, Prisma, Role, TrustTag } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { PartiesService } from "./parties.service";

describe("PartiesService", () => {
  let service: PartiesService;
  let prisma: {
    party: {
      findMany: jest.Mock;
      findUnique: jest.Mock;
      findFirst: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
    };
    deal: {
      findMany: jest.Mock;
    };
    payment: {
      findMany: jest.Mock;
    };
    callLog: {
      findMany: jest.Mock;
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
      party: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      deal: {
        findMany: jest.fn().mockResolvedValue([]),
      },
      payment: {
        findMany: jest.fn().mockResolvedValue([]),
      },
      callLog: {
        findMany: jest.fn().mockResolvedValue([]),
      },
    };

    service = new PartiesService(prisma as unknown as PrismaService);
  });

  it("creates a party scoped to the current user", async () => {
    prisma.party.findUnique.mockResolvedValueOnce(null);
    prisma.party.create.mockImplementation(async ({ data }) => party(data));

    const result = await service.create(user, {
      id: "8a03ea67-a2ac-4caf-a10b-ec64af074d7e",
      name: " Amit Verma ",
      phone: " 98765 ",
      syncId: "sync-1",
    });

    expect(prisma.party.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        id: "8a03ea67-a2ac-4caf-a10b-ec64af074d7e",
        userId: "user-1",
        name: "Amit Verma",
        phone: "98765",
        type: PartyType.CUSTOMER,
        trustTag: TrustTag.NEW,
        syncId: "sync-1",
      }),
    });
    expect(result).toMatchObject({
      id: "8a03ea67-a2ac-4caf-a10b-ec64af074d7e",
      name: "Amit Verma",
      stats: {
        dealCount: 0,
        pendingAmount: "0.00",
        avgDelayDays: null,
        overdueAmount: "0.00",
      },
    });
  });

  it("returns the existing party when syncId is duplicated", async () => {
    prisma.party.findUnique.mockResolvedValueOnce(party({ syncId: "sync-1" }));

    const result = await service.create(user, {
      name: "Duplicate",
      syncId: "sync-1",
    });

    expect(prisma.party.create).not.toHaveBeenCalled();
    expect(result).toMatchObject({ syncId: "sync-1" });
  });

  it("restores a soft-deleted party when syncId is re-sent", async () => {
    prisma.party.findUnique.mockResolvedValueOnce(
      party({ syncId: "sync-1", deletedAt: new Date() }),
    );
    prisma.party.update.mockImplementation(async ({ data }) =>
      party({ ...data, deletedAt: null }),
    );

    const result = await service.create(user, {
      name: "Restored Amit",
      syncId: "sync-1",
      type: PartyType.BOTH,
    });

    expect(prisma.party.update).toHaveBeenCalledWith({
      where: { id: "party-1" },
      data: {
        name: "Restored Amit",
        phone: null,
        type: PartyType.BOTH,
        trustTag: TrustTag.NEW,
        notes: null,
        deletedAt: null,
      },
    });
    expect(result).toMatchObject({ name: "Restored Amit", deletedAt: null });
  });

  it("rejects duplicate syncId owned by another user", async () => {
    prisma.party.findUnique.mockResolvedValueOnce(
      party({ userId: "user-2", syncId: "sync-1" }),
    );

    await expect(
      service.create(user, { name: "Duplicate", syncId: "sync-1" }),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it("lists active parties with search and type filters", async () => {
    prisma.party.findMany.mockResolvedValueOnce([party({ name: "Amit" })]);

    await service.list(user, {
      search: "amit",
      type: PartyType.CUSTOMER,
      trustTag: TrustTag.RELIABLE,
    });

    expect(prisma.party.findMany).toHaveBeenCalledWith({
      where: {
        userId: "user-1",
        deletedAt: null,
        type: PartyType.CUSTOMER,
        trustTag: TrustTag.RELIABLE,
        OR: [
          { name: { contains: "amit", mode: "insensitive" } },
          { phone: { contains: "amit", mode: "insensitive" } },
        ],
      },
      orderBy: [{ updatedAt: "desc" }, { name: "asc" }],
    });
  });

  it("updates only a party owned by the current user", async () => {
    prisma.party.findFirst.mockResolvedValueOnce(party());
    prisma.party.update.mockImplementation(async ({ data }) =>
      party({ name: data.name }),
    );

    const result = await service.update(user, "party-1", {
      name: "Ramesh",
      notes: "",
    });

    expect(prisma.party.findFirst).toHaveBeenCalledWith({
      where: { id: "party-1", userId: "user-1", deletedAt: null },
    });
    expect(prisma.party.update).toHaveBeenCalledWith({
      where: { id: "party-1" },
      data: { name: "Ramesh", notes: null },
    });
    expect(result).toMatchObject({ name: "Ramesh" });
  });

  it("soft deletes active parties", async () => {
    prisma.party.findFirst.mockResolvedValueOnce(party());
    prisma.party.update.mockImplementation(async ({ data }) =>
      party({ deletedAt: data.deletedAt }),
    );

    const result = await service.remove(user, "party-1");

    expect(prisma.party.update).toHaveBeenCalledWith({
      where: { id: "party-1" },
      data: { deletedAt: expect.any(Date) },
    });
    expect(result.deletedAt).toEqual(expect.any(String));
  });

  it("rejects missing or deleted parties", async () => {
    prisma.party.findFirst.mockResolvedValueOnce(null);

    await expect(service.get(user, "missing-party")).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it("returns empty ledger defaults", async () => {
    prisma.party.findFirst.mockResolvedValueOnce(party());
    prisma.deal.findMany.mockResolvedValueOnce([]);

    await expect(service.ledger(user, "party-1")).resolves.toEqual({
      receivable: "0.00",
      payable: "0.00",
      net: "0.00",
      overdueAmount: "0.00",
      oldestOverdueDate: null,
    });
  });

  it("computes ledger totals from sales and purchases", async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    prisma.party.findFirst.mockResolvedValueOnce(party());
    prisma.deal.findMany.mockResolvedValueOnce([
      {
        type: DealType.SALE,
        totalAmount: new Prisma.Decimal(1000),
        paidAmount: new Prisma.Decimal(200),
        paymentDue: yesterday,
      },
      {
        type: DealType.PURCHASE,
        totalAmount: new Prisma.Decimal(500),
        paidAmount: new Prisma.Decimal(100),
        paymentDue: null,
      },
    ]);

    await expect(service.ledger(user, "party-1")).resolves.toEqual({
      receivable: "800.00",
      payable: "400.00",
      net: "400.00",
      overdueAmount: "800.00",
      oldestOverdueDate: yesterday.toISOString(),
    });
  });
});

function party(overrides: Record<string, unknown> = {}) {
  return partyShape(overrides);
}

function partyShape(overrides: Record<string, unknown> = {}) {
  const now = new Date("2026-06-06T10:00:00.000Z");
  return {
    id: "party-1",
    userId: "user-1",
    name: "Amit Verma",
    phone: "98765",
    type: PartyType.CUSTOMER,
    trustTag: TrustTag.NEW,
    notes: null,
    syncId: "sync-1",
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    ...overrides,
  };
}
