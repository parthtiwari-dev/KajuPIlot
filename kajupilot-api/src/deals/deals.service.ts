import {
  BadRequestException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from "@nestjs/common";
import {
  Deal,
  DealItem,
  DealStatus,
  DealType,
  Party,
  Prisma,
} from "@prisma/client";
import { randomUUID } from "crypto";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { PrismaService } from "../prisma/prisma.service";
import { CreateDealDto, DealItemDto } from "./dto/create-deal.dto";
import { ListDealsDto } from "./dto/list-deals.dto";
import { UpdateDealDto } from "./dto/update-deal.dto";

type DealWithPartyAndItems = Deal & {
  party: Pick<Party, "id" | "name" | "phone" | "type" | "trustTag">;
  items: DealItem[];
};

const allowedNextStatus: Record<DealStatus, DealStatus | null> = {
  [DealStatus.QUOTED]: DealStatus.CONFIRMED,
  [DealStatus.CONFIRMED]: DealStatus.DELIVERED,
  [DealStatus.DELIVERED]: DealStatus.PAID,
  [DealStatus.PAID]: null,
};

@Injectable()
export class DealsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(user: AuthenticatedUser, query: ListDealsDto) {
    const where: Prisma.DealWhereInput = {
      userId: user.id,
      deletedAt: null,
      ...(query.status ? { status: query.status } : {}),
      ...(query.partyId ? { partyId: query.partyId } : {}),
      ...(query.grade
        ? {
            OR: [
              {
                cashewGrade: {
                  contains: query.grade.trim(),
                  mode: "insensitive",
                },
              },
              {
                items: {
                  some: {
                    grade: {
                      contains: query.grade.trim(),
                      mode: "insensitive",
                    },
                  },
                },
              },
            ],
          }
        : {}),
      ...(query.from || query.to
        ? {
            createdAt: {
              ...(query.from ? { gte: new Date(query.from) } : {}),
              ...(query.to ? { lte: new Date(query.to) } : {}),
            },
          }
        : {}),
    };

    const deals = await this.prisma.deal.findMany({
      where,
      include: this.dealInclude(),
      orderBy: [{ updatedAt: "desc" }, { createdAt: "desc" }],
    });

    return deals.map((deal) => this.toJson(deal));
  }

  async create(user: AuthenticatedUser, dto: CreateDealDto) {
    const existing = await this.prisma.deal.findUnique({
      where: { syncId: dto.syncId },
      include: this.dealInclude(),
    });

    if (existing) {
      if (existing.userId !== user.id) {
        throw new UnauthorizedException("Invalid sync id");
      }

      if (existing.deletedAt) {
        await this.findActiveParty(user.id, dto.partyId);
        const restored = await this.prisma.deal.update({
          where: { id: existing.id },
          data: {
            ...this.createData(user.id, dto),
            deletedAt: null,
            items: {
              deleteMany: {},
              create: this.itemCreateData(dto.items),
            },
          },
          include: this.dealInclude(),
        });

        return this.toJson(restored);
      }

      return this.toJson(existing);
    }

    await this.findActiveParty(user.id, dto.partyId);
    const deal = await this.prisma.deal.create({
      data: {
        id: dto.id ?? randomUUID(),
        ...this.createData(user.id, dto),
        items: {
          create: this.itemCreateData(dto.items),
        },
      },
      include: this.dealInclude(),
    });

    return this.toJson(deal);
  }

  async get(user: AuthenticatedUser, id: string) {
    const deal = await this.findActiveDeal(user.id, id);
    return this.toJson(deal);
  }

  async update(user: AuthenticatedUser, id: string, dto: UpdateDealDto) {
    const existing = await this.findActiveDeal(user.id, id);

    if (dto.partyId !== undefined) {
      await this.findActiveParty(user.id, dto.partyId);
    }

    const totalAmount =
      dto.totalAmount === undefined
        ? new Prisma.Decimal(existing.totalAmount)
        : this.decimal(dto.totalAmount);
    const paidAmount =
      dto.paidAmount === undefined
        ? new Prisma.Decimal(existing.paidAmount)
        : this.decimal(dto.paidAmount);

    this.assertPaidIsFullyCovered(existing.status, paidAmount, totalAmount);

    const itemSummary =
      dto.items === undefined ? null : this.itemSummary(dto.items);

    const deal = await this.prisma.deal.update({
      where: { id },
      data: {
        ...(dto.partyId !== undefined ? { partyId: dto.partyId } : {}),
        ...(dto.type !== undefined ? { type: dto.type } : {}),
        ...(dto.items !== undefined
          ? {
              cashewGrade: itemSummary?.grade,
              quantityKg: new Prisma.Decimal(0),
              ratePerKg: new Prisma.Decimal(0),
              items: {
                deleteMany: {},
                create: this.itemCreateData(dto.items),
              },
            }
          : {}),
        ...(dto.totalAmount !== undefined ? { totalAmount } : {}),
        ...(dto.paidAmount !== undefined ? { paidAmount } : {}),
        ...(dto.deliveryDate !== undefined
          ? { deliveryDate: this.optionalDate(dto.deliveryDate) }
          : {}),
        ...(dto.paymentDue !== undefined
          ? { paymentDue: this.optionalDate(dto.paymentDue) }
          : {}),
        ...(dto.notes !== undefined
          ? { notes: this.cleanNullable(dto.notes) }
          : {}),
      },
      include: this.dealInclude(),
    });

    return this.toJson(deal);
  }

  async updateStatus(
    user: AuthenticatedUser,
    id: string,
    targetStatus: DealStatus,
  ) {
    const deal = await this.findActiveDeal(user.id, id);

    if (deal.status === targetStatus) {
      return this.toJson(deal);
    }

    if (allowedNextStatus[deal.status] !== targetStatus) {
      throw new BadRequestException("Invalid status transition");
    }

    this.assertPaidIsFullyCovered(
      targetStatus,
      new Prisma.Decimal(deal.paidAmount),
      new Prisma.Decimal(deal.totalAmount),
    );

    const updated = await this.prisma.deal.update({
      where: { id },
      data: { status: targetStatus },
      include: this.dealInclude(),
    });

    return this.toJson(updated);
  }

  async remove(user: AuthenticatedUser, id: string) {
    await this.findActiveDeal(user.id, id);
    const deleted = await this.prisma.deal.update({
      where: { id },
      data: { deletedAt: new Date() },
      include: this.dealInclude(),
    });

    return this.toJson(deleted);
  }

  private createData(userId: string, dto: CreateDealDto) {
    const totalAmount = this.decimal(dto.totalAmount);
    const paidAmount = this.decimal(dto.paidAmount ?? "0");
    const status = dto.status ?? DealStatus.CONFIRMED;
    const summary = this.itemSummary(dto.items);

    this.assertPaidIsFullyCovered(status, paidAmount, totalAmount);

    return {
      userId,
      partyId: dto.partyId,
      type: dto.type ?? DealType.SALE,
      cashewGrade: summary.grade,
      quantityKg: new Prisma.Decimal(0),
      ratePerKg: new Prisma.Decimal(0),
      totalAmount,
      paidAmount,
      deliveryDate: this.optionalDate(dto.deliveryDate),
      paymentDue: this.optionalDate(dto.paymentDue),
      notes: this.cleanNullable(dto.notes),
      status,
      syncId: dto.syncId,
    };
  }

  private itemCreateData(items: DealItemDto[]) {
    return items.map((item, index) => ({
      id: item.id ?? randomUUID(),
      grade: item.grade.trim(),
      quantityText: item.quantityText.trim(),
      rateText: this.cleanNullable(item.rateText),
      totalAmount: this.decimal(item.totalAmount),
      sortOrder: index,
    }));
  }

  private itemSummary(items: DealItemDto[]) {
    const grades = items
      .map((item) => item.grade.trim())
      .filter((grade) => grade.length > 0);

    return {
      grade:
        grades.length === 0
          ? "Mixed"
          : grades.length === 1
            ? grades[0]
            : `${grades[0]} + ${grades.length - 1}`,
    };
  }

  private async findActiveDeal(userId: string, id: string) {
    const deal = await this.prisma.deal.findFirst({
      where: { id, userId, deletedAt: null },
      include: this.dealInclude(),
    });

    if (!deal) {
      throw new NotFoundException("Deal not found");
    }

    return deal;
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

  private toJson(deal: DealWithPartyAndItems) {
    return {
      id: deal.id,
      userId: deal.userId,
      partyId: deal.partyId,
      type: deal.type,
      cashewGrade: deal.cashewGrade,
      quantityKg: this.decimalString(deal.quantityKg),
      ratePerKg: this.decimalString(deal.ratePerKg),
      totalAmount: this.decimalString(deal.totalAmount),
      paidAmount: this.decimalString(deal.paidAmount),
      status: deal.status,
      deliveryDate: deal.deliveryDate?.toISOString() ?? null,
      paymentDue: deal.paymentDue?.toISOString() ?? null,
      notes: deal.notes,
      syncId: deal.syncId,
      createdAt: deal.createdAt.toISOString(),
      updatedAt: deal.updatedAt.toISOString(),
      deletedAt: deal.deletedAt?.toISOString() ?? null,
      party: {
        id: deal.party.id,
        name: deal.party.name,
        phone: deal.party.phone,
        type: deal.party.type,
        trustTag: deal.party.trustTag,
      },
      items: deal.items.map((item) => ({
        id: item.id,
        grade: item.grade,
        quantityText: item.quantityText,
        rateText: item.rateText,
        totalAmount: this.decimalString(item.totalAmount),
        sortOrder: item.sortOrder,
        createdAt: item.createdAt.toISOString(),
        updatedAt: item.updatedAt.toISOString(),
      })),
    };
  }

  private assertPaidIsFullyCovered(
    status: DealStatus,
    paidAmount: Prisma.Decimal,
    totalAmount: Prisma.Decimal,
  ) {
    if (status === DealStatus.PAID && paidAmount.lessThan(totalAmount)) {
      throw new BadRequestException("Paid status requires full payment");
    }
  }

  private dealInclude() {
    return {
      party: { select: this.partySelect() },
      items: { orderBy: { sortOrder: "asc" as const } },
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

  private decimal(value: string) {
    return new Prisma.Decimal(value);
  }

  private decimalString(value: Prisma.Decimal | number | string) {
    return new Prisma.Decimal(value).toFixed(2);
  }

  private optionalDate(value?: string | null) {
    return value ? new Date(value) : null;
  }

  private cleanNullable(value?: string | null) {
    const trimmed = value?.trim();
    return trimmed ? trimmed : null;
  }
}
