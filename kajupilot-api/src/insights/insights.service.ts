import { Injectable } from "@nestjs/common";
import {
  DealStatus,
  DealType,
  ExpenseCategory,
  ExpenseScope,
  PartyType,
  PaymentType,
  Prisma,
  TaskStatus,
  TaskType,
  TrustTag,
} from "@prisma/client";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { PrismaService } from "../prisma/prisma.service";

type PartyWithActivity = {
  id: string;
  name: string;
  phone: string | null;
  type: PartyType;
  trustTag: TrustTag;
  trustTagManualOverride: boolean;
  createdAt: Date;
  updatedAt: Date;
  deals: Array<{
    id: string;
    type: DealType;
    totalAmount: Prisma.Decimal;
    paidAmount: Prisma.Decimal;
    paymentDue: Date | null;
    createdAt: Date;
    updatedAt: Date;
  }>;
  payments: Array<{
    id: string;
    type: PaymentType;
    amount: Prisma.Decimal;
    paymentDate: Date;
    deal: { type: DealType; paymentDue: Date | null } | null;
  }>;
  callLogs: Array<{ createdAt: Date }>;
};

@Injectable()
export class InsightsService {
  constructor(private readonly prisma: PrismaService) {}

  async today(user: AuthenticatedUser, date?: string) {
    const { start, end } = this.dayRange(date);
    const [parties, callsDue, deliveriesDue, overdueTasks, topCallsToday] =
      await Promise.all([
        this.prisma.party.findMany({
          where: { userId: user.id, deletedAt: null },
          include: {
            deals: {
              where: { deletedAt: null },
              select: {
                id: true,
                type: true,
                totalAmount: true,
                paidAmount: true,
                paymentDue: true,
              },
            },
            payments: {
              where: { deletedAt: null, dealId: null },
              select: { type: true, amount: true },
            },
          },
        }),
        this.prisma.task.count({
          where: {
            userId: user.id,
            deletedAt: null,
            type: TaskType.CALL,
            status: { in: [TaskStatus.PENDING, TaskStatus.POSTPONED] },
            scheduledAt: { lt: end },
          },
        }),
        this.prisma.task.count({
          where: {
            userId: user.id,
            deletedAt: null,
            type: TaskType.DELIVERY,
            status: { in: [TaskStatus.PENDING, TaskStatus.POSTPONED] },
            scheduledAt: { lt: end },
          },
        }),
        this.prisma.task.count({
          where: {
            userId: user.id,
            deletedAt: null,
            status: { in: [TaskStatus.PENDING, TaskStatus.POSTPONED] },
            scheduledAt: { lt: start },
          },
        }),
        this.prisma.task.findMany({
          where: {
            userId: user.id,
            deletedAt: null,
            type: TaskType.CALL,
            status: { in: [TaskStatus.PENDING, TaskStatus.POSTPONED] },
            scheduledAt: { lt: end },
          },
          include: {
            party: {
              select: {
                id: true,
                name: true,
                phone: true,
                type: true,
                trustTag: true,
              },
            },
          },
          take: 5,
          orderBy: [{ priority: "desc" }, { scheduledAt: "asc" }],
        }),
      ]);

    const pendingCollection = parties.reduce(
      (total, party) =>
        total.plus(this.partyReceivable(party.deals, party.payments)),
      new Prisma.Decimal(0),
    );
    const overdueDeals = parties.reduce((count, party) => {
      return (
        count +
        party.deals.filter((deal) => {
          const pending = new Prisma.Decimal(deal.totalAmount).minus(
            deal.paidAmount,
          );
          return (
            deal.type === DealType.SALE &&
            pending.greaterThan(0) &&
            deal.paymentDue !== null &&
            deal.paymentDue < start
          );
        }).length
      );
    }, 0);

    return {
      pendingCollection: this.decimalString(pendingCollection),
      callsDue,
      deliveriesDue,
      overdueCount: overdueTasks + overdueDeals,
      topCallsToday: topCallsToday.map((task) => ({
        taskId: task.id,
        partyId: task.partyId,
        name: task.party?.name ?? task.title,
        phone: task.party?.phone ?? null,
        reason: task.title,
        scheduledAt: task.scheduledAt.toISOString(),
        priority: task.priority,
      })),
    };
  }

  async weekly(user: AuthenticatedUser, to?: string) {
    const { from, end, labelTo } = this.periodRange(to, 7);
    const [payments, expenses, dealsClosedCount, newPartiesCount, parties] =
      await Promise.all([
        this.prisma.payment.findMany({
          where: {
            userId: user.id,
            deletedAt: null,
            paymentDate: { gte: from, lt: end },
          },
          select: { type: true, amount: true },
        }),
        this.prisma.expense.findMany({
          where: {
            userId: user.id,
            deletedAt: null,
            expenseDate: { gte: from, lt: end },
          },
          select: { category: true, scope: true, amount: true },
        }),
        this.prisma.deal.count({
          where: {
            userId: user.id,
            deletedAt: null,
            status: DealStatus.PAID,
            updatedAt: { gte: from, lt: end },
          },
        }),
        this.prisma.party.count({
          where: {
            userId: user.id,
            deletedAt: null,
            createdAt: { gte: from, lt: end },
          },
        }),
        this.partiesWithActivity(user.id, from, end),
      ]);

    const revenue = this.sumPayments(payments, PaymentType.RECEIVED);
    const businessExpenses = this.sumExpenses(expenses, ExpenseScope.BUSINESS);
    const personalExpenses = this.sumExpenses(expenses, ExpenseScope.PERSONAL);
    const expenseBreakdown = this.expenseBreakdown(expenses);
    const peopleMetrics = this.peopleMetrics(parties, from, end);

    return {
      period: {
        from: this.dateOnly(from),
        to: labelTo,
      },
      revenue: revenue.toFixed(2),
      businessExpenses: businessExpenses.toFixed(2),
      personalExpenses: personalExpenses.toFixed(2),
      grossProfitEstimate: revenue.minus(businessExpenses).toFixed(2),
      dealsClosedCount,
      newPartiesCount,
      topBuyers: peopleMetrics.topBuyers,
      slowestPayers: peopleMetrics.slowPayers,
      expenseBreakdown,
    };
  }

  async people(user: AuthenticatedUser, to?: string) {
    const { from, end } = this.periodRange(to, 30);
    const parties = await this.partiesWithActivity(user.id, from, end);
    const metrics = this.peopleMetrics(parties, from, end);
    const trustTagUpdates = await this.applySlowPayerTrustTags(
      user.id,
      metrics.slowPayers,
    );

    return {
      topBuyers: metrics.topBuyers,
      slowPayers: metrics.slowPayers,
      inactiveCustomers: metrics.inactiveCustomers,
      trustTagUpdates,
    };
  }

  private partiesWithActivity(userId: string, from: Date, end: Date) {
    return this.prisma.party.findMany({
      where: { userId, deletedAt: null },
      include: {
        deals: {
          where: { deletedAt: null },
          select: {
            id: true,
            type: true,
            totalAmount: true,
            paidAmount: true,
            paymentDue: true,
            createdAt: true,
            updatedAt: true,
          },
        },
        payments: {
          where: { deletedAt: null },
          select: {
            id: true,
            type: true,
            amount: true,
            paymentDate: true,
            deal: {
              select: {
                type: true,
                paymentDue: true,
              },
            },
          },
        },
        callLogs: {
          where: { createdAt: { lt: end } },
          select: { createdAt: true },
        },
      },
    }) as Promise<PartyWithActivity[]>;
  }

  private peopleMetrics(parties: PartyWithActivity[], from: Date, end: Date) {
    const topBuyers = parties
      .map((party) => {
        const saleDeals = party.deals.filter((deal) => {
          return (
            deal.type === DealType.SALE &&
            deal.createdAt >= from &&
            deal.createdAt < end
          );
        });
        const amount = saleDeals.reduce(
          (total, deal) => total.plus(deal.totalAmount),
          new Prisma.Decimal(0),
        );
        return {
          partyId: party.id,
          name: party.name,
          phone: party.phone,
          trustTag: party.trustTag,
          amount: amount.toFixed(2),
          dealCount: saleDeals.length,
        };
      })
      .filter((item) => item.dealCount > 0)
      .sort((a, b) =>
        new Prisma.Decimal(b.amount).comparedTo(new Prisma.Decimal(a.amount)),
      )
      .slice(0, 3);

    const slowPayers = parties
      .map((party) => this.slowPayerMetric(party, end))
      .filter((item) => item.avgDelayDays > 0 || item.overdueAmount !== "0.00")
      .sort((a, b) => {
        if (b.avgDelayDays !== a.avgDelayDays) {
          return b.avgDelayDays - a.avgDelayDays;
        }
        return new Prisma.Decimal(b.overdueAmount).comparedTo(
          new Prisma.Decimal(a.overdueAmount),
        );
      })
      .slice(0, 5);

    const inactiveCustomers = parties
      .filter((party) => {
        return (
          party.type === PartyType.CUSTOMER || party.type === PartyType.BOTH
        );
      })
      .map((party) => {
        const lastActivityAt = this.lastActivityAt(party);
        return {
          partyId: party.id,
          name: party.name,
          phone: party.phone,
          trustTag: party.trustTag,
          lastActivityAt: lastActivityAt?.toISOString() ?? null,
          daysInactive: lastActivityAt
            ? this.daysBetween(lastActivityAt, end)
            : null,
        };
      })
      .filter((item) => {
        return item.lastActivityAt !== null && (item.daysInactive ?? 0) >= 30;
      })
      .sort((a, b) => (b.daysInactive ?? 0) - (a.daysInactive ?? 0))
      .slice(0, 5);

    return { topBuyers, slowPayers, inactiveCustomers };
  }

  private slowPayerMetric(party: PartyWithActivity, asOf: Date) {
    const delays: number[] = [];
    let overdueAmount = new Prisma.Decimal(0);

    for (const payment of party.payments) {
      const due = payment.deal?.paymentDue;
      if (
        payment.type !== PaymentType.RECEIVED ||
        payment.deal?.type !== DealType.SALE ||
        !due ||
        payment.paymentDate <= due
      ) {
        continue;
      }
      delays.push(this.daysBetween(due, payment.paymentDate));
    }

    for (const deal of party.deals) {
      if (deal.type !== DealType.SALE || !deal.paymentDue) {
        continue;
      }
      const pending = new Prisma.Decimal(deal.totalAmount).minus(
        deal.paidAmount,
      );
      if (pending.greaterThan(0) && deal.paymentDue < asOf) {
        delays.push(this.daysBetween(deal.paymentDue, asOf));
        overdueAmount = overdueAmount.plus(pending);
      }
    }

    const avgDelayDays =
      delays.length === 0
        ? 0
        : Math.round(
            delays.reduce((total, value) => total + value, 0) / delays.length,
          );

    return {
      partyId: party.id,
      name: party.name,
      phone: party.phone,
      trustTag: party.trustTag,
      avgDelayDays,
      overdueAmount: overdueAmount.toFixed(2),
      latePaymentCount: delays.length,
      trustTagManualOverride: party.trustTagManualOverride,
    };
  }

  private async applySlowPayerTrustTags(
    userId: string,
    slowPayers: Array<{
      partyId: string;
      name: string;
      avgDelayDays: number;
      trustTag: TrustTag;
      trustTagManualOverride: boolean;
    }>,
  ) {
    const updates = [];
    for (const party of slowPayers) {
      if (
        party.avgDelayDays <= 7 ||
        party.trustTagManualOverride ||
        party.trustTag === TrustTag.SLOW_PAYER
      ) {
        continue;
      }

      await this.prisma.party.updateMany({
        where: { id: party.partyId, userId },
        data: { trustTag: TrustTag.SLOW_PAYER },
      });
      updates.push({
        partyId: party.partyId,
        name: party.name,
        previousTrustTag: party.trustTag,
        trustTag: TrustTag.SLOW_PAYER,
        avgDelayDays: party.avgDelayDays,
      });
    }
    return updates;
  }

  private expenseBreakdown(
    expenses: Array<{
      category: ExpenseCategory;
      scope: ExpenseScope;
      amount: Prisma.Decimal;
    }>,
  ) {
    const byCategory = Object.fromEntries(
      Object.values(ExpenseCategory).map((category) => [category, "0.00"]),
    );
    const byScope = Object.fromEntries(
      Object.values(ExpenseScope).map((scope) => [scope, "0.00"]),
    );

    for (const expense of expenses) {
      const amount = new Prisma.Decimal(expense.amount);
      byCategory[expense.category] = new Prisma.Decimal(
        byCategory[expense.category],
      )
        .plus(amount)
        .toFixed(2);
      byScope[expense.scope] = new Prisma.Decimal(byScope[expense.scope])
        .plus(amount)
        .toFixed(2);
    }

    return { byCategory, byScope };
  }

  private sumPayments(
    payments: Array<{ type: PaymentType; amount: Prisma.Decimal }>,
    type: PaymentType,
  ) {
    return payments.reduce((total, payment) => {
      if (payment.type !== type) {
        return total;
      }
      return total.plus(payment.amount);
    }, new Prisma.Decimal(0));
  }

  private sumExpenses(
    expenses: Array<{ scope: ExpenseScope; amount: Prisma.Decimal }>,
    scope: ExpenseScope,
  ) {
    return expenses.reduce((total, expense) => {
      if (expense.scope !== scope) {
        return total;
      }
      return total.plus(expense.amount);
    }, new Prisma.Decimal(0));
  }

  private partyReceivable(
    deals: Array<{
      type: DealType;
      totalAmount: Prisma.Decimal;
      paidAmount: Prisma.Decimal;
    }>,
    payments: Array<{ type: PaymentType; amount: Prisma.Decimal }>,
  ) {
    const salePending = deals.reduce((total, deal) => {
      if (deal.type !== DealType.SALE) {
        return total;
      }
      return total.plus(
        new Prisma.Decimal(deal.totalAmount).minus(deal.paidAmount),
      );
    }, new Prisma.Decimal(0));
    const unlinkedReceived = payments.reduce((total, payment) => {
      if (payment.type !== PaymentType.RECEIVED) {
        return total;
      }
      return total.plus(payment.amount);
    }, new Prisma.Decimal(0));
    return Prisma.Decimal.max(0, salePending.minus(unlinkedReceived));
  }

  private lastActivityAt(party: PartyWithActivity) {
    const dates = [
      ...party.deals.map((deal) => deal.createdAt),
      ...party.payments.map((payment) => payment.paymentDate),
      ...party.callLogs.map((callLog) => callLog.createdAt),
    ];
    if (dates.length === 0) {
      return null;
    }
    return dates.sort((a, b) => b.getTime() - a.getTime())[0];
  }

  private periodRange(to: string | undefined, days: number) {
    const labelTo = to ?? this.dateOnly(new Date());
    const toStart = this.dateStart(labelTo);
    const end = new Date(toStart);
    end.setUTCDate(end.getUTCDate() + 1);
    const from = new Date(end);
    from.setUTCDate(from.getUTCDate() - days);
    return { from, end, labelTo };
  }

  private dayRange(date?: string) {
    const start = this.dateStart(date ?? this.dateOnly(new Date()));
    const end = new Date(start);
    end.setUTCDate(end.getUTCDate() + 1);
    return { start, end };
  }

  private dateStart(date: string) {
    const start = new Date(`${date}T00:00:00.000Z`);
    start.setUTCHours(0, 0, 0, 0);
    return start;
  }

  private dateOnly(date: Date) {
    return date.toISOString().slice(0, 10);
  }

  private decimalString(value: Prisma.Decimal | number | string) {
    return new Prisma.Decimal(value).toFixed(2);
  }

  private daysBetween(from: Date, to: Date) {
    const millisecondsPerDay = 24 * 60 * 60 * 1000;
    return Math.max(
      0,
      Math.ceil((to.getTime() - from.getTime()) / millisecondsPerDay),
    );
  }
}
