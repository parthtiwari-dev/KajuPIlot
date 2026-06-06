import {
  BadRequestException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from "@nestjs/common";
import { Expense, ExpenseCategory, Prisma } from "@prisma/client";
import { randomUUID } from "crypto";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { PrismaService } from "../prisma/prisma.service";
import { CreateExpenseDto } from "./dto/create-expense.dto";
import { ListExpensesDto } from "./dto/list-expenses.dto";
import { UpdateExpenseDto } from "./dto/update-expense.dto";

@Injectable()
export class ExpensesService {
  constructor(private readonly prisma: PrismaService) {}

  async list(user: AuthenticatedUser, query: ListExpensesDto) {
    const expenses = await this.prisma.expense.findMany({
      where: this.where(user.id, query),
      orderBy: [{ expenseDate: "desc" }, { updatedAt: "desc" }],
    });

    return expenses.map((expense) => this.toJson(expense));
  }

  async create(user: AuthenticatedUser, dto: CreateExpenseDto) {
    this.assertPositiveAmount(dto.amount);
    const existing = await this.prisma.expense.findUnique({
      where: { syncId: dto.syncId },
    });

    if (existing) {
      if (existing.userId !== user.id) {
        throw new UnauthorizedException("Invalid sync id");
      }

      if (existing.deletedAt) {
        const restored = await this.prisma.expense.update({
          where: { id: existing.id },
          data: {
            category: dto.category,
            amount: this.decimal(dto.amount),
            notes: this.cleanNullable(dto.notes),
            expenseDate: new Date(dto.expenseDate),
            deletedAt: null,
          },
        });

        return this.toJson(restored);
      }

      return this.toJson(existing);
    }

    const expense = await this.prisma.expense.create({
      data: {
        id: dto.id ?? randomUUID(),
        userId: user.id,
        category: dto.category,
        amount: this.decimal(dto.amount),
        notes: this.cleanNullable(dto.notes),
        expenseDate: new Date(dto.expenseDate),
        syncId: dto.syncId,
      },
    });

    return this.toJson(expense);
  }

  async update(user: AuthenticatedUser, id: string, dto: UpdateExpenseDto) {
    await this.findActiveExpense(user.id, id);
    if (dto.amount !== undefined) {
      this.assertPositiveAmount(dto.amount);
    }

    const expense = await this.prisma.expense.update({
      where: { id },
      data: {
        ...(dto.category !== undefined ? { category: dto.category } : {}),
        ...(dto.amount !== undefined
          ? { amount: this.decimal(dto.amount) }
          : {}),
        ...(dto.notes !== undefined
          ? { notes: this.cleanNullable(dto.notes) }
          : {}),
        ...(dto.expenseDate !== undefined
          ? { expenseDate: new Date(dto.expenseDate) }
          : {}),
      },
    });

    return this.toJson(expense);
  }

  async remove(user: AuthenticatedUser, id: string) {
    await this.findActiveExpense(user.id, id);
    const expense = await this.prisma.expense.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    return this.toJson(expense);
  }

  async summary(user: AuthenticatedUser, query: ListExpensesDto) {
    const expenses = await this.prisma.expense.findMany({
      where: this.where(user.id, query),
      select: { category: true, amount: true },
    });
    const byCategory = Object.fromEntries(
      ExpenseCategoryValues.map((category) => [category, "0.00"]),
    );
    let total = new Prisma.Decimal(0);

    for (const expense of expenses) {
      const amount = new Prisma.Decimal(expense.amount);
      total = total.plus(amount);
      byCategory[expense.category] = new Prisma.Decimal(
        byCategory[expense.category],
      )
        .plus(amount)
        .toFixed(2);
    }

    return {
      byCategory,
      total: total.toFixed(2),
      periodComparison: await this.periodComparison(user.id, query, total),
    };
  }

  private async findActiveExpense(userId: string, id: string) {
    const expense = await this.prisma.expense.findFirst({
      where: { id, userId, deletedAt: null },
    });

    if (!expense) {
      throw new NotFoundException("Expense not found");
    }

    return expense;
  }

  private where(userId: string, query: ListExpensesDto) {
    return {
      userId,
      deletedAt: null,
      ...(query.category ? { category: query.category } : {}),
      ...(query.from || query.to
        ? {
            expenseDate: {
              ...(query.from ? { gte: new Date(query.from) } : {}),
              ...(query.to ? { lte: new Date(query.to) } : {}),
            },
          }
        : {}),
    };
  }

  private async periodComparison(
    userId: string,
    query: ListExpensesDto,
    currentTotal: Prisma.Decimal,
  ) {
    if (!query.from || !query.to) {
      return 0;
    }

    const from = new Date(query.from);
    const to = new Date(query.to);
    const duration = to.getTime() - from.getTime();
    if (duration <= 0) {
      return 0;
    }

    const previousTo = new Date(from.getTime());
    const previousFrom = new Date(from.getTime() - duration);
    const previousExpenses = await this.prisma.expense.findMany({
      where: {
        userId,
        deletedAt: null,
        ...(query.category ? { category: query.category } : {}),
        expenseDate: {
          gte: previousFrom,
          lt: previousTo,
        },
      },
      select: { amount: true },
    });
    const previousTotal = previousExpenses.reduce(
      (total, expense) => total.plus(new Prisma.Decimal(expense.amount)),
      new Prisma.Decimal(0),
    );

    if (previousTotal.equals(0)) {
      return 0;
    }

    return Number(
      currentTotal
        .minus(previousTotal)
        .dividedBy(previousTotal)
        .times(100)
        .toFixed(2),
    );
  }

  private toJson(expense: Expense) {
    return {
      id: expense.id,
      userId: expense.userId,
      category: expense.category,
      amount: this.decimalString(expense.amount),
      notes: expense.notes,
      expenseDate: expense.expenseDate.toISOString(),
      syncId: expense.syncId,
      createdAt: expense.createdAt.toISOString(),
      updatedAt: expense.updatedAt.toISOString(),
      deletedAt: expense.deletedAt?.toISOString() ?? null,
    };
  }

  private assertPositiveAmount(value: string) {
    if (this.decimal(value).lessThanOrEqualTo(0)) {
      throw new BadRequestException("Amount must be greater than zero");
    }
  }

  private decimal(value: string) {
    return new Prisma.Decimal(value);
  }

  private decimalString(value: Prisma.Decimal | number | string) {
    return new Prisma.Decimal(value).toFixed(2);
  }

  private cleanNullable(value?: string | null) {
    const trimmed = value?.trim();
    return trimmed ? trimmed : null;
  }
}

const ExpenseCategoryValues = Object.values(ExpenseCategory);
