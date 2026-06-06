import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from "@nestjs/common";
import {
  DealType,
  Party,
  PartyType,
  PaymentType,
  Prisma,
  TrustTag,
} from "@prisma/client";
import { randomUUID } from "crypto";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { PrismaService } from "../prisma/prisma.service";
import { CreatePartyDto } from "./dto/create-party.dto";
import { ListPartiesDto } from "./dto/list-parties.dto";
import { UpdatePartyDto } from "./dto/update-party.dto";

type DealForLedger = {
  type: DealType;
  totalAmount: Prisma.Decimal | number | string;
  paidAmount: Prisma.Decimal | number | string;
  paymentDue: Date | null;
};

type PaymentForLedger = {
  type: PaymentType;
  amount: Prisma.Decimal | number | string;
};

@Injectable()
export class PartiesService {
  constructor(private readonly prisma: PrismaService) {}

  async list(user: AuthenticatedUser, query: ListPartiesDto) {
    const where: Prisma.PartyWhereInput = {
      userId: user.id,
      deletedAt: null,
      ...(query.type ? { type: query.type } : {}),
      ...(query.trustTag ? { trustTag: query.trustTag } : {}),
      ...(query.search
        ? {
            OR: [
              { name: { contains: query.search, mode: "insensitive" } },
              { phone: { contains: query.search, mode: "insensitive" } },
            ],
          }
        : {}),
    };

    const parties = await this.prisma.party.findMany({
      where,
      orderBy: [{ updatedAt: "desc" }, { name: "asc" }],
    });

    return Promise.all(parties.map((party) => this.withStats(user.id, party)));
  }

  async create(user: AuthenticatedUser, dto: CreatePartyDto) {
    const existing = await this.prisma.party.findUnique({
      where: { syncId: dto.syncId },
    });

    if (existing) {
      if (existing.userId !== user.id) {
        throw new UnauthorizedException("Invalid sync id");
      }

      if (existing.deletedAt) {
        const restored = await this.prisma.party.update({
          where: { id: existing.id },
          data: {
            name: dto.name.trim(),
            phone: this.cleanNullable(dto.phone),
            type: dto.type ?? existing.type,
            trustTag: dto.trustTag ?? existing.trustTag,
            notes: this.cleanNullable(dto.notes),
            deletedAt: null,
          },
        });

        return this.withStats(user.id, restored);
      }

      return this.withStats(user.id, existing);
    }

    const party = await this.prisma.party.create({
      data: {
        id: dto.id ?? randomUUID(),
        userId: user.id,
        name: dto.name.trim(),
        phone: this.cleanNullable(dto.phone),
        type: dto.type ?? PartyType.CUSTOMER,
        trustTag: dto.trustTag ?? TrustTag.NEW,
        notes: this.cleanNullable(dto.notes),
        syncId: dto.syncId,
      },
    });

    return this.withStats(user.id, party);
  }

  async get(user: AuthenticatedUser, id: string) {
    const party = await this.findActiveParty(user.id, id);
    return this.withStats(user.id, party);
  }

  async update(user: AuthenticatedUser, id: string, dto: UpdatePartyDto) {
    await this.findActiveParty(user.id, id);

    const party = await this.prisma.party.update({
      where: { id },
      data: {
        ...(dto.name !== undefined ? { name: dto.name.trim() } : {}),
        ...(dto.phone !== undefined
          ? { phone: this.cleanNullable(dto.phone) }
          : {}),
        ...(dto.type !== undefined ? { type: dto.type } : {}),
        ...(dto.trustTag !== undefined ? { trustTag: dto.trustTag } : {}),
        ...(dto.notes !== undefined
          ? { notes: this.cleanNullable(dto.notes) }
          : {}),
      },
    });

    return this.withStats(user.id, party);
  }

  async remove(user: AuthenticatedUser, id: string) {
    await this.findActiveParty(user.id, id);

    const party = await this.prisma.party.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    return this.toJson(party);
  }

  async ledger(user: AuthenticatedUser, id: string) {
    await this.findActiveParty(user.id, id);
    const [deals, payments] = await Promise.all([
      this.dealsForParty(user.id, id),
      this.unlinkedPaymentsForParty(user.id, id),
    ]);
    const totals = this.computeLedger(deals, payments);

    return {
      receivable: totals.receivable.toFixed(2),
      payable: totals.payable.toFixed(2),
      net: totals.net.toFixed(2),
      overdueAmount: totals.overdueAmount.toFixed(2),
      oldestOverdueDate: totals.oldestOverdueDate?.toISOString() ?? null,
    };
  }

  async history(user: AuthenticatedUser, id: string) {
    await this.findActiveParty(user.id, id);

    const [deals, payments, callLogs] = await Promise.all([
      this.prisma.deal.findMany({
        where: { userId: user.id, partyId: id, deletedAt: null },
        orderBy: { createdAt: "desc" },
      }),
      this.prisma.payment.findMany({
        where: { userId: user.id, partyId: id, deletedAt: null },
        orderBy: { paymentDate: "desc" },
      }),
      this.prisma.callLog.findMany({
        where: { userId: user.id, partyId: id },
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return {
      deals: deals.map((deal) => ({
        ...deal,
        quantityKg: this.decimalString(deal.quantityKg),
        ratePerKg: this.decimalString(deal.ratePerKg),
        totalAmount: this.decimalString(deal.totalAmount),
        paidAmount: this.decimalString(deal.paidAmount),
      })),
      payments: payments.map((payment) => ({
        id: payment.id,
        userId: payment.userId,
        partyId: payment.partyId,
        dealId: payment.dealId,
        type: payment.type,
        amount: this.decimalString(payment.amount),
        method: payment.method,
        notes: payment.notes,
        paymentDate: payment.paymentDate.toISOString(),
        syncId: payment.syncId,
        createdAt: payment.createdAt.toISOString(),
        updatedAt: payment.updatedAt.toISOString(),
        deletedAt: payment.deletedAt?.toISOString() ?? null,
      })),
      callLogs: callLogs.map((callLog) => ({
        ...callLog,
        promisedAmount: callLog.promisedAmount
          ? this.decimalString(callLog.promisedAmount)
          : null,
      })),
    };
  }

  private async findActiveParty(userId: string, id: string) {
    const party = await this.prisma.party.findFirst({
      where: { id, userId, deletedAt: null },
    });

    if (!party) {
      throw new NotFoundException("Party not found");
    }

    return party;
  }

  private async withStats(userId: string, party: Party) {
    const [deals, payments] = await Promise.all([
      this.dealsForParty(userId, party.id),
      this.unlinkedPaymentsForParty(userId, party.id),
    ]);
    const totals = this.computeLedger(deals, payments);

    return {
      ...this.toJson(party),
      stats: {
        dealCount: deals.length,
        pendingAmount: totals.net.toFixed(2),
        avgDelayDays: null,
        overdueAmount: totals.overdueAmount.toFixed(2),
      },
    };
  }

  private toJson(party: Party) {
    return {
      id: party.id,
      userId: party.userId,
      name: party.name,
      phone: party.phone,
      type: party.type,
      trustTag: party.trustTag,
      notes: party.notes,
      syncId: party.syncId,
      createdAt: party.createdAt.toISOString(),
      updatedAt: party.updatedAt.toISOString(),
      deletedAt: party.deletedAt?.toISOString() ?? null,
    };
  }

  private dealsForParty(userId: string, partyId: string) {
    return this.prisma.deal.findMany({
      where: { userId, partyId, deletedAt: null },
      select: {
        type: true,
        totalAmount: true,
        paidAmount: true,
        paymentDue: true,
      },
    });
  }

  private unlinkedPaymentsForParty(userId: string, partyId: string) {
    return this.prisma.payment.findMany({
      where: { userId, partyId, dealId: null, deletedAt: null },
      select: {
        type: true,
        amount: true,
      },
    });
  }

  private computeLedger(
    deals: DealForLedger[],
    unlinkedPayments: PaymentForLedger[] = [],
  ) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let receivable = new Prisma.Decimal(0);
    let payable = new Prisma.Decimal(0);
    let overdueReceivable = new Prisma.Decimal(0);
    let overduePayable = new Prisma.Decimal(0);
    let oldestOverdueDate: Date | null = null;

    for (const deal of deals) {
      const remaining = new Prisma.Decimal(deal.totalAmount).minus(
        new Prisma.Decimal(deal.paidAmount),
      );

      if (remaining.lessThanOrEqualTo(0)) {
        continue;
      }

      if (deal.type === DealType.SALE) {
        receivable = receivable.plus(remaining);
      } else {
        payable = payable.plus(remaining);
      }

      if (deal.paymentDue && deal.paymentDue < today) {
        if (deal.type === DealType.SALE) {
          overdueReceivable = overdueReceivable.plus(remaining);
        } else {
          overduePayable = overduePayable.plus(remaining);
        }
        if (!oldestOverdueDate || deal.paymentDue < oldestOverdueDate) {
          oldestOverdueDate = deal.paymentDue;
        }
      }
    }

    for (const payment of unlinkedPayments) {
      const amount = new Prisma.Decimal(payment.amount);
      if (payment.type === PaymentType.RECEIVED) {
        receivable = Prisma.Decimal.max(
          new Prisma.Decimal(0),
          receivable.minus(amount),
        );
        overdueReceivable = Prisma.Decimal.max(
          new Prisma.Decimal(0),
          overdueReceivable.minus(amount),
        );
      } else {
        payable = Prisma.Decimal.max(
          new Prisma.Decimal(0),
          payable.minus(amount),
        );
        overduePayable = Prisma.Decimal.max(
          new Prisma.Decimal(0),
          overduePayable.minus(amount),
        );
      }
    }

    const overdueAmount = overdueReceivable.plus(overduePayable);

    return {
      receivable,
      payable,
      net: receivable.minus(payable),
      overdueAmount,
      oldestOverdueDate: overdueAmount.greaterThan(0)
        ? oldestOverdueDate
        : null,
    };
  }

  private cleanNullable(value?: string | null) {
    const trimmed = value?.trim();
    return trimmed ? trimmed : null;
  }

  private decimalString(value: Prisma.Decimal | number | string) {
    return new Prisma.Decimal(value).toFixed(2);
  }
}
