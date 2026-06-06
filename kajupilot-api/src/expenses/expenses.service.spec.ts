import { BadRequestException, UnauthorizedException } from "@nestjs/common";
import { ExpenseCategory, ExpenseScope, Prisma, Role } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { ExpensesService } from "./expenses.service";

describe("ExpensesService", () => {
  let service: ExpensesService;
  let prisma: {
    expense: {
      findMany: jest.Mock;
      findUnique: jest.Mock;
      findFirst: jest.Mock;
      create: jest.Mock;
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
      expense: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
    };
    service = new ExpensesService(prisma as unknown as PrismaService);
  });

  it("creates an expense scoped to the current user", async () => {
    prisma.expense.findUnique.mockResolvedValueOnce(null);
    prisma.expense.create.mockImplementation(async ({ data }) => expense(data));

    const result = await service.create(user, createDto());

    expect(prisma.expense.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        id: "expense-1",
        userId: "user-1",
        category: ExpenseCategory.TRANSPORT,
        scope: ExpenseScope.BUSINESS,
        amount: new Prisma.Decimal("1250.00"),
        syncId: "sync-1",
      }),
    });
    expect(result).toMatchObject({
      id: "expense-1",
      amount: "1250.00",
      category: ExpenseCategory.TRANSPORT,
      scope: ExpenseScope.BUSINESS,
    });
  });

  it("returns existing same-user expense when syncId is duplicated", async () => {
    prisma.expense.findUnique.mockResolvedValueOnce(expense());

    const result = await service.create(user, createDto());

    expect(prisma.expense.create).not.toHaveBeenCalled();
    expect(result.syncId).toBe("sync-1");
  });

  it("rejects duplicate syncId owned by another user", async () => {
    prisma.expense.findUnique.mockResolvedValueOnce(
      expense({ userId: "user-2" }),
    );

    await expect(service.create(user, createDto())).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });

  it("rejects zero amount", async () => {
    await expect(
      service.create(user, createDto({ amount: "0.00" })),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it("updates and soft deletes active expenses", async () => {
    prisma.expense.findFirst.mockResolvedValue(expense());
    prisma.expense.update.mockImplementation(async ({ data }) =>
      expense({
        ...data,
        amount: data.amount ?? new Prisma.Decimal("1250.00"),
      }),
    );

    const updated = await service.update(user, "expense-1", {
      category: ExpenseCategory.LABOUR,
      scope: ExpenseScope.PERSONAL,
      amount: "2200.00",
    });
    const deleted = await service.remove(user, "expense-1");

    expect(updated.category).toBe(ExpenseCategory.LABOUR);
    expect(updated.scope).toBe(ExpenseScope.PERSONAL);
    expect(updated.amount).toBe("2200.00");
    expect(deleted.deletedAt).toEqual(expect.any(String));
  });

  it("returns category summary totals", async () => {
    prisma.expense.findMany.mockResolvedValueOnce([
      expense({
        category: ExpenseCategory.TRANSPORT,
        scope: ExpenseScope.BUSINESS,
        amount: new Prisma.Decimal("100.00"),
      }),
      expense({
        category: ExpenseCategory.LABOUR,
        scope: ExpenseScope.PERSONAL,
        amount: new Prisma.Decimal("250.00"),
      }),
    ]);

    await expect(service.summary(user, {})).resolves.toMatchObject({
      total: "350.00",
      periodComparison: 0,
      byCategory: {
        TRANSPORT: "100.00",
        LABOUR: "250.00",
      },
      byScope: {
        BUSINESS: "100.00",
        PERSONAL: "250.00",
      },
    });
  });
});

function createDto(overrides: Record<string, unknown> = {}) {
  return {
    id: "expense-1",
    category: ExpenseCategory.TRANSPORT,
    scope: ExpenseScope.BUSINESS,
    amount: "1250.00",
    expenseDate: "2026-06-07T00:00:00.000Z",
    notes: "Truck",
    syncId: "sync-1",
    ...overrides,
  };
}

function expense(overrides: Record<string, unknown> = {}) {
  const now = new Date("2026-06-07T00:00:00.000Z");
  return {
    id: "expense-1",
    userId: "user-1",
    category: ExpenseCategory.TRANSPORT,
    scope: ExpenseScope.BUSINESS,
    amount: new Prisma.Decimal("1250.00"),
    notes: "Truck",
    expenseDate: now,
    syncId: "sync-1",
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    ...overrides,
  };
}
