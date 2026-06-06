import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from "@nestjs/common";
import { DealType, Party, PartyType, Prisma, TrustTag } from "@prisma/client";
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
    const deals = await this.dealsForParty(user.id, id);
    const totals = this.computeLedger(deals);

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
        ...payment,
        amount: this.decimalString(payment.amount),
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
    const deals = await this.dealsForParty(userId, party.id);
    const totals = this.computeLedger(deals);

    return {
      ...this.toJson(party),
      stats: {
        dealCount: deals.length,
        pendingAmount: totals.net.toFixed(2),
        avgDelayDays: 0,
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

  private computeLedger(deals: DealForLedger[]) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let receivable = new Prisma.Decimal(0);
    let payable = new Prisma.Decimal(0);
    let overdueAmount = new Prisma.Decimal(0);
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
        overdueAmount = overdueAmount.plus(remaining);
        if (!oldestOverdueDate || deal.paymentDue < oldestOverdueDate) {
          oldestOverdueDate = deal.paymentDue;
        }
      }
    }

    return {
      receivable,
      payable,
      net: receivable.minus(payable),
      overdueAmount,
      oldestOverdueDate,
    };
  }

  private cleanNullable(value?: string) {
    const trimmed = value?.trim();
    return trimmed ? trimmed : null;
  }

  private decimalString(value: Prisma.Decimal | number | string) {
    return new Prisma.Decimal(value).toFixed(2);
  }
}
