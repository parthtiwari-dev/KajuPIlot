import { Injectable } from "@nestjs/common";
import {
  DealType,
  PaymentType,
  Prisma,
  TaskStatus,
  TaskType,
} from "@prisma/client";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { PrismaService } from "../prisma/prisma.service";

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

  private dayRange(date?: string) {
    const start = date ? new Date(`${date}T00:00:00.000Z`) : new Date();
    start.setUTCHours(0, 0, 0, 0);
    const end = new Date(start);
    end.setUTCDate(end.getUTCDate() + 1);
    return { start, end };
  }

  private decimalString(value: Prisma.Decimal | number | string) {
    return new Prisma.Decimal(value).toFixed(2);
  }
}
