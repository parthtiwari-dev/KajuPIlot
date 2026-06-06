import {
  BadRequestException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from "@nestjs/common";
import {
  Deal,
  DealType,
  Party,
  Payment,
  PaymentType,
  Prisma,
} from "@prisma/client";
import { randomUUID } from "crypto";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { PrismaService } from "../prisma/prisma.service";
import { CreatePaymentDto } from "./dto/create-payment.dto";
import { ListPaymentsDto } from "./dto/list-payments.dto";
import { UpdatePaymentDto } from "./dto/update-payment.dto";

type PaymentWithRelations = Payment & {
  party: Pick<Party, "id" | "name" | "phone" | "type" | "trustTag">;
  deal: Pick<
    Deal,
    "id" | "partyId" | "type" | "cashewGrade" | "totalAmount" | "paidAmount"
  > | null;
};

type DealForPayment = Pick<
  Deal,
  "id" | "partyId" | "type" | "totalAmount" | "paidAmount"
>;

@Injectable()
export class PaymentsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(user: AuthenticatedUser, query: ListPaymentsDto) {
    const payments = await this.prisma.payment.findMany({
      where: {
        userId: user.id,
        deletedAt: null,
        ...(query.partyId ? { partyId: query.partyId } : {}),
        ...(query.dealId ? { dealId: query.dealId } : {}),
        ...(query.type ? { type: query.type } : {}),
        ...(query.from || query.to
          ? {
              paymentDate: {
                ...(query.from ? { gte: new Date(query.from) } : {}),
                ...(query.to ? { lte: new Date(query.to) } : {}),
              },
            }
          : {}),
      },
      include: this.paymentInclude(),
      orderBy: [{ paymentDate: "desc" }, { updatedAt: "desc" }],
    });

    return payments.map((payment) => this.toJson(payment));
  }

  async create(user: AuthenticatedUser, dto: CreatePaymentDto) {
    this.assertPositiveAmount(dto.amount);
    const existing = await this.prisma.payment.findUnique({
      where: { syncId: dto.syncId },
      include: this.paymentInclude(),
    });

    if (existing) {
      if (existing.userId !== user.id) {
        throw new UnauthorizedException("Invalid sync id");
      }

      if (!existing.deletedAt) {
        return this.toJson(existing);
      }

      await this.findActiveParty(user.id, dto.partyId);
      const amount = this.decimal(dto.amount);
      const restored = await this.prisma.$transaction(async (tx) => {
        if (dto.dealId) {
          await this.applyLinkedDealPayment(
            tx,
            user.id,
            dto.partyId,
            dto.dealId,
            dto.type,
            amount,
          );
        }

        return tx.payment.update({
          where: { id: existing.id },
          data: {
            partyId: dto.partyId,
            dealId: dto.dealId ?? null,
            type: dto.type,
            amount,
            method: this.cleanNullable(dto.method),
            notes: this.cleanNullable(dto.notes),
            paymentDate: new Date(dto.paymentDate),
            deletedAt: null,
          },
          include: this.paymentInclude(),
        });
      });

      return this.toJson(restored);
    }

    await this.findActiveParty(user.id, dto.partyId);
    const amount = this.decimal(dto.amount);
    const payment = await this.prisma.$transaction(async (tx) => {
      if (dto.dealId) {
        await this.applyLinkedDealPayment(
          tx,
          user.id,
          dto.partyId,
          dto.dealId,
          dto.type,
          amount,
        );
      }

      return tx.payment.create({
        data: {
          id: dto.id ?? randomUUID(),
          userId: user.id,
          partyId: dto.partyId,
          dealId: dto.dealId ?? null,
          type: dto.type,
          amount,
          method: this.cleanNullable(dto.method),
          notes: this.cleanNullable(dto.notes),
          paymentDate: new Date(dto.paymentDate),
          syncId: dto.syncId,
        },
        include: this.paymentInclude(),
      });
    });

    return this.toJson(payment);
  }

  async update(user: AuthenticatedUser, id: string, dto: UpdatePaymentDto) {
    const existing = await this.findActivePayment(user.id, id);
    const partyId = dto.partyId ?? existing.partyId;
    const dealId = dto.dealId === undefined ? existing.dealId : dto.dealId;
    const type = dto.type ?? existing.type;
    const amount =
      dto.amount === undefined
        ? new Prisma.Decimal(existing.amount)
        : this.decimal(dto.amount);

    if (dto.amount !== undefined) {
      this.assertPositiveAmount(dto.amount);
    }
    await this.findActiveParty(user.id, partyId);

    const payment = await this.prisma.$transaction(async (tx) => {
      if (existing.dealId) {
        await this.reverseLinkedDealPayment(
          tx,
          user.id,
          existing.dealId,
          existing.amount,
        );
      }

      if (dealId) {
        await this.applyLinkedDealPayment(
          tx,
          user.id,
          partyId,
          dealId,
          type,
          amount,
        );
      }

      return tx.payment.update({
        where: { id },
        data: {
          ...(dto.partyId !== undefined ? { partyId } : {}),
          ...(dto.dealId !== undefined ? { dealId } : {}),
          ...(dto.type !== undefined ? { type } : {}),
          ...(dto.amount !== undefined ? { amount } : {}),
          ...(dto.method !== undefined
            ? { method: this.cleanNullable(dto.method) }
            : {}),
          ...(dto.notes !== undefined
            ? { notes: this.cleanNullable(dto.notes) }
            : {}),
          ...(dto.paymentDate !== undefined
            ? { paymentDate: new Date(dto.paymentDate) }
            : {}),
        },
        include: this.paymentInclude(),
      });
    });

    return this.toJson(payment);
  }

  async remove(user: AuthenticatedUser, id: string) {
    const existing = await this.findActivePayment(user.id, id);
    const deleted = await this.prisma.$transaction(async (tx) => {
      if (existing.dealId) {
        await this.reverseLinkedDealPayment(
          tx,
          user.id,
          existing.dealId,
          existing.amount,
        );
      }

      return tx.payment.update({
        where: { id },
        data: { deletedAt: new Date() },
        include: this.paymentInclude(),
      });
    });

    return this.toJson(deleted);
  }

  async ledger(user: AuthenticatedUser) {
    const parties = await this.prisma.party.findMany({
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
            updatedAt: true,
          },
        },
        payments: {
          where: { deletedAt: null, dealId: null },
          select: {
            type: true,
            amount: true,
            paymentDate: true,
          },
        },
      },
      orderBy: [{ updatedAt: "desc" }, { name: "asc" }],
    });

    let totalReceivable = new Prisma.Decimal(0);
    let totalPayable = new Prisma.Decimal(0);
    const overdueParties: Record<string, unknown>[] = [];

    for (const party of parties) {
      const totals = this.computePartyLedger(party.deals, party.payments);
      totalReceivable = totalReceivable.plus(totals.receivable);
      totalPayable = totalPayable.plus(totals.payable);

      if (totals.overdueAmount.greaterThan(0)) {
        overdueParties.push({
          partyId: party.id,
          name: party.name,
          phone: party.phone,
          type: party.type,
          receivable: totals.receivable.toFixed(2),
          payable: totals.payable.toFixed(2),
          net: totals.receivable.minus(totals.payable).toFixed(2),
          overdueAmount: totals.overdueAmount.toFixed(2),
          oldestOverdueDate: totals.oldestOverdueDate?.toISOString() ?? null,
          dealCount: party.deals.length,
        });
      }
    }

    return {
      totalReceivable: totalReceivable.toFixed(2),
      totalPayable: totalPayable.toFixed(2),
      net: totalReceivable.minus(totalPayable).toFixed(2),
      overdueParties,
    };
  }

  private async findActivePayment(userId: string, id: string) {
    const payment = await this.prisma.payment.findFirst({
      where: { id, userId, deletedAt: null },
      include: this.paymentInclude(),
    });

    if (!payment) {
      throw new NotFoundException("Payment not found");
    }

    return payment;
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

  private async applyLinkedDealPayment(
    tx: Prisma.TransactionClient,
    userId: string,
    partyId: string,
    dealId: string,
    paymentType: PaymentType,
    amount: Prisma.Decimal,
  ) {
    const deal = await tx.deal.findFirst({
      where: { id: dealId, userId, partyId, deletedAt: null },
      select: {
        id: true,
        partyId: true,
        type: true,
        totalAmount: true,
        paidAmount: true,
      },
    });

    if (!deal) {
      throw new NotFoundException("Deal not found");
    }

    this.assertCompatiblePaymentType(deal, paymentType);
    const nextPaid = new Prisma.Decimal(deal.paidAmount).plus(amount);
    if (nextPaid.greaterThan(new Prisma.Decimal(deal.totalAmount))) {
      throw new BadRequestException("Payment exceeds deal total");
    }

    await tx.deal.update({
      where: { id: deal.id },
      data: { paidAmount: nextPaid },
    });
  }

  private async reverseLinkedDealPayment(
    tx: Prisma.TransactionClient,
    userId: string,
    dealId: string,
    amount: Prisma.Decimal | number | string,
  ) {
    const deal = await tx.deal.findFirst({
      where: { id: dealId, userId },
      select: {
        id: true,
        paidAmount: true,
      },
    });

    if (!deal) {
      return;
    }

    const nextPaid = Prisma.Decimal.max(
      new Prisma.Decimal(0),
      new Prisma.Decimal(deal.paidAmount).minus(new Prisma.Decimal(amount)),
    );

    await tx.deal.update({
      where: { id: deal.id },
      data: { paidAmount: nextPaid },
    });
  }

  private assertCompatiblePaymentType(
    deal: DealForPayment,
    paymentType: PaymentType,
  ) {
    if (deal.type === DealType.SALE && paymentType !== PaymentType.RECEIVED) {
      throw new BadRequestException("Sale deals require received payments");
    }

    if (deal.type === DealType.PURCHASE && paymentType !== PaymentType.PAID) {
      throw new BadRequestException("Purchase deals require paid payments");
    }
  }

  private computePartyLedger(
    deals: {
      type: DealType;
      totalAmount: Prisma.Decimal | number | string;
      paidAmount: Prisma.Decimal | number | string;
      paymentDue: Date | null;
    }[],
    unlinkedPayments: {
      type: PaymentType;
      amount: Prisma.Decimal | number | string;
    }[],
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
      overdueAmount,
      oldestOverdueDate: overdueAmount.greaterThan(0)
        ? oldestOverdueDate
        : null,
    };
  }

  private toJson(payment: PaymentWithRelations) {
    return {
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
      party: {
        id: payment.party.id,
        name: payment.party.name,
        phone: payment.party.phone,
        type: payment.party.type,
        trustTag: payment.party.trustTag,
      },
      deal: payment.deal
        ? {
            id: payment.deal.id,
            partyId: payment.deal.partyId,
            type: payment.deal.type,
            cashewGrade: payment.deal.cashewGrade,
            totalAmount: this.decimalString(payment.deal.totalAmount),
            paidAmount: this.decimalString(payment.deal.paidAmount),
          }
        : null,
    };
  }

  private paymentInclude() {
    return {
      party: { select: this.partySelect() },
      deal: {
        select: {
          id: true,
          partyId: true,
          type: true,
          cashewGrade: true,
          totalAmount: true,
          paidAmount: true,
        },
      },
    } as const;
  }

  private partySelect() {
    return {
      id: true,
      name: true,
      phone: true,
      type: true,
      trustTag: true,
    } as const;
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
