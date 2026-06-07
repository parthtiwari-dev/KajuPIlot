import { Injectable, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import {
  DealType,
  PaymentType,
  Prisma,
  Role,
  TaskStatus,
} from "@prisma/client";
import {
  AdminActivityQueryDto,
  AdminActivityRange,
  AdminAiLogsQueryDto,
  AdminAiLogStatus,
  AdminExportFormat,
  AdminExportQueryDto,
  AdminExportTable,
  AdminStatsQueryDto,
} from "./dto/admin-query.dto";
import { AdminLoginDto } from "./dto/admin-login.dto";
import { PrismaService } from "../prisma/prisma.service";

type ActivityKind =
  | "deal"
  | "payment"
  | "expense"
  | "task"
  | "callLog"
  | "aiParse";

interface ActivityItem {
  kind: ActivityKind;
  id: string;
  userId: string;
  userName: string;
  title: string;
  amount: string | null;
  status: string | null;
  occurredAt: string;
  meta: Record<string, unknown>;
}

@Injectable()
export class AdminService {
  private readonly aiLogPageSize = 25;

  constructor(
    private readonly configService: ConfigService,
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
  ) {}

  async login(dto: AdminLoginDto) {
    const expectedUser = this.configService.get<string>("ADMIN_USER");
    const expectedSecret = this.configService.get<string>("ADMIN_SECRET");

    if (
      !expectedUser ||
      !expectedSecret ||
      dto.username !== expectedUser ||
      dto.secret !== expectedSecret
    ) {
      throw new UnauthorizedException("Invalid admin credentials");
    }

    const adminToken = await this.jwtService.signAsync(
      {
        sub: expectedUser,
        role: Role.ADMIN,
        typ: "admin",
      },
      {
        secret: this.configService.getOrThrow<string>("JWT_SECRET"),
        expiresIn: "12h",
      },
    );

    return {
      adminToken,
      expiresInSeconds: 60 * 60 * 12,
      user: {
        username: expectedUser,
        role: Role.ADMIN,
      },
    };
  }

  async stats(query: AdminStatsQueryDto) {
    const { start, end, label } = this.dayRange(query.date);
    const [
      activeUserIds,
      dealsCreated,
      aiParseCalls,
      aiConfirmed,
      aiErrors,
      paymentsLogged,
      pendingCollection,
      recentActivity,
      totalUsers,
    ] = await Promise.all([
      this.activeUserIds(start, end),
      this.prisma.deal.count({
        where: { createdAt: { gte: start, lt: end } },
      }),
      this.prisma.aiParseLog.count({
        where: { createdAt: { gte: start, lt: end } },
      }),
      this.prisma.aiParseLog.count({
        where: {
          createdAt: { gte: start, lt: end },
          confirmed: true,
        },
      }),
      this.prisma.aiParseLog.count({
        where: {
          createdAt: { gte: start, lt: end },
          error: { not: null },
        },
      }),
      this.prisma.payment.count({
        where: { createdAt: { gte: start, lt: end } },
      }),
      this.systemPendingCollection(),
      this.activityItems({ start, end, take: 12 }),
      this.prisma.user.count(),
    ]);

    return {
      date: label,
      activeUsers: activeUserIds.size,
      totalUsers,
      dealsCreated,
      aiParseCalls,
      paymentsLogged,
      pendingCollection,
      aiParse: {
        total: aiParseCalls,
        confirmed: aiConfirmed,
        unconfirmed: Math.max(aiParseCalls - aiConfirmed - aiErrors, 0),
        errors: aiErrors,
        successRate:
          aiParseCalls === 0
            ? 0
            : Number(((aiConfirmed / aiParseCalls) * 100).toFixed(2)),
      },
      recentActivity,
    };
  }

  async users() {
    const users = await this.prisma.user.findMany({
      select: {
        id: true,
        name: true,
        businessName: true,
        role: true,
        createdAt: true,
        updatedAt: true,
        _count: {
          select: {
            parties: true,
            deals: true,
            payments: true,
            expenses: true,
            tasks: true,
            callLogs: true,
            aiParseLogs: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    return users.map((user) => this.serialize(user));
  }

  async user(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        businessName: true,
        role: true,
        createdAt: true,
        updatedAt: true,
        parties: { orderBy: [{ deletedAt: "asc" }, { updatedAt: "desc" }] },
        deals: {
          include: {
            party: { select: this.partySelect() },
            items: { orderBy: { sortOrder: "asc" } },
          },
          orderBy: { updatedAt: "desc" },
        },
        payments: {
          include: {
            party: { select: this.partySelect() },
            deal: { select: { id: true, type: true, cashewGrade: true } },
          },
          orderBy: { createdAt: "desc" },
        },
        expenses: { orderBy: { createdAt: "desc" } },
        tasks: {
          include: { party: { select: this.partySelect() } },
          orderBy: { scheduledAt: "desc" },
        },
        callLogs: {
          include: {
            party: { select: this.partySelect() },
            task: { select: { id: true, title: true, type: true } },
          },
          orderBy: { createdAt: "desc" },
        },
        aiParseLogs: { orderBy: { createdAt: "desc" }, take: 100 },
      },
    });

    if (!user) {
      throw new UnauthorizedException("User not found");
    }

    const activity = await this.activityItems({
      userId: id,
      ...this.rangeForActivity(AdminActivityRange.TODAY),
      take: 50,
    });

    return this.serialize({
      ...user,
      timelineToday: activity,
    });
  }

  async userActivity(id: string, query: AdminActivityQueryDto) {
    await this.assertUserExists(id);
    const range = this.rangeForActivity(
      query.range ?? AdminActivityRange.TODAY,
    );
    return {
      userId: id,
      range: query.range ?? AdminActivityRange.TODAY,
      items: await this.activityItems({ userId: id, ...range, take: 200 }),
    };
  }

  async aiLogs(query: AdminAiLogsQueryDto) {
    const page = query.page ?? 1;
    const where = this.aiLogWhere(query);
    const [total, items] = await Promise.all([
      this.prisma.aiParseLog.count({ where }),
      this.prisma.aiParseLog.findMany({
        where,
        include: {
          user: {
            select: {
              id: true,
              name: true,
              businessName: true,
              role: true,
            },
          },
        },
        orderBy: { createdAt: "desc" },
        skip: (page - 1) * this.aiLogPageSize,
        take: this.aiLogPageSize,
      }),
    ]);

    return {
      page,
      pageSize: this.aiLogPageSize,
      total,
      totalPages: Math.max(Math.ceil(total / this.aiLogPageSize), 1),
      items: this.serialize(items),
    };
  }

  async aiLog(id: string) {
    const log = await this.prisma.aiParseLog.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            businessName: true,
            role: true,
          },
        },
      },
    });

    if (!log) {
      throw new UnauthorizedException("AI log not found");
    }

    return this.serialize(log);
  }

  async exportData(query: AdminExportQueryDto) {
    const records = await this.exportRecords(query);
    const serialized = this.serialize(records) as Record<string, unknown>[];

    if (query.format === AdminExportFormat.CSV) {
      return {
        contentType: "text/csv; charset=utf-8",
        filename: `${query.table}.csv`,
        body: this.toCsv(serialized),
      };
    }

    return {
      contentType: "application/json; charset=utf-8",
      filename: `${query.table}.json`,
      body: JSON.stringify(
        {
          table: query.table,
          generatedAt: new Date().toISOString(),
          count: serialized.length,
          records: serialized,
        },
        null,
        2,
      ),
    };
  }

  private async activeUserIds(start: Date, end: Date) {
    const [deals, payments, expenses, tasks, callLogs, aiLogs] =
      await Promise.all([
        this.prisma.deal.findMany({
          where: { createdAt: { gte: start, lt: end } },
          distinct: ["userId"],
          select: { userId: true },
        }),
        this.prisma.payment.findMany({
          where: { createdAt: { gte: start, lt: end } },
          distinct: ["userId"],
          select: { userId: true },
        }),
        this.prisma.expense.findMany({
          where: { createdAt: { gte: start, lt: end } },
          distinct: ["userId"],
          select: { userId: true },
        }),
        this.prisma.task.findMany({
          where: { createdAt: { gte: start, lt: end } },
          distinct: ["userId"],
          select: { userId: true },
        }),
        this.prisma.callLog.findMany({
          where: { createdAt: { gte: start, lt: end } },
          distinct: ["userId"],
          select: { userId: true },
        }),
        this.prisma.aiParseLog.findMany({
          where: { createdAt: { gte: start, lt: end } },
          distinct: ["userId"],
          select: { userId: true },
        }),
      ]);

    return new Set(
      [
        ...deals,
        ...payments,
        ...expenses,
        ...tasks,
        ...callLogs,
        ...aiLogs,
      ].map((row) => row.userId),
    );
  }

  private async systemPendingCollection() {
    const parties = await this.prisma.party.findMany({
      where: { deletedAt: null },
      include: {
        deals: {
          where: { deletedAt: null },
          select: { type: true, totalAmount: true, paidAmount: true },
        },
        payments: {
          where: { deletedAt: null, dealId: null },
          select: { type: true, amount: true },
        },
      },
    });

    const pending = parties.reduce((total, party) => {
      let receivable = party.deals.reduce((sum, deal) => {
        if (deal.type !== DealType.SALE) {
          return sum;
        }

        const remaining = new Prisma.Decimal(deal.totalAmount).minus(
          deal.paidAmount,
        );
        return remaining.greaterThan(0) ? sum.plus(remaining) : sum;
      }, new Prisma.Decimal(0));

      for (const payment of party.payments) {
        if (payment.type === PaymentType.RECEIVED) {
          receivable = Prisma.Decimal.max(
            new Prisma.Decimal(0),
            receivable.minus(payment.amount),
          );
        }
      }

      return total.plus(receivable);
    }, new Prisma.Decimal(0));

    return pending.toFixed(2);
  }

  private async activityItems(options: {
    userId?: string;
    start: Date;
    end: Date;
    take: number;
  }) {
    const userFilter = options.userId ? { userId: options.userId } : {};
    const [deals, payments, expenses, tasks, callLogs, aiLogs] =
      await Promise.all([
        this.prisma.deal.findMany({
          where: {
            ...userFilter,
            createdAt: { gte: options.start, lt: options.end },
          },
          include: {
            user: { select: this.userSelect() },
            party: { select: this.partySelect() },
            items: { orderBy: { sortOrder: "asc" } },
          },
          orderBy: { createdAt: "desc" },
          take: options.take,
        }),
        this.prisma.payment.findMany({
          where: {
            ...userFilter,
            createdAt: { gte: options.start, lt: options.end },
          },
          include: {
            user: { select: this.userSelect() },
            party: { select: this.partySelect() },
          },
          orderBy: { createdAt: "desc" },
          take: options.take,
        }),
        this.prisma.expense.findMany({
          where: {
            ...userFilter,
            createdAt: { gte: options.start, lt: options.end },
          },
          include: { user: { select: this.userSelect() } },
          orderBy: { createdAt: "desc" },
          take: options.take,
        }),
        this.prisma.task.findMany({
          where: {
            ...userFilter,
            createdAt: { gte: options.start, lt: options.end },
          },
          include: {
            user: { select: this.userSelect() },
            party: { select: this.partySelect() },
          },
          orderBy: { createdAt: "desc" },
          take: options.take,
        }),
        this.prisma.callLog.findMany({
          where: {
            ...userFilter,
            createdAt: { gte: options.start, lt: options.end },
          },
          include: {
            user: { select: this.userSelect() },
            party: { select: this.partySelect() },
          },
          orderBy: { createdAt: "desc" },
          take: options.take,
        }),
        this.prisma.aiParseLog.findMany({
          where: {
            ...userFilter,
            createdAt: { gte: options.start, lt: options.end },
          },
          include: { user: { select: this.userSelect() } },
          orderBy: { createdAt: "desc" },
          take: options.take,
        }),
      ]);

    const items: ActivityItem[] = [
      ...deals.map((deal) => ({
        kind: "deal" as const,
        id: deal.id,
        userId: deal.userId,
        userName: deal.user.name,
        title: `${deal.type} deal with ${deal.party.name}`,
        amount: this.decimalString(deal.totalAmount),
        status: deal.status,
        occurredAt: deal.createdAt.toISOString(),
        meta: {
          party: deal.party,
          items: deal.items.map((item) => ({
            grade: item.grade,
            quantityText: item.quantityText,
            rateText: item.rateText,
            totalAmount: this.decimalString(item.totalAmount),
          })),
        },
      })),
      ...payments.map((payment) => ({
        kind: "payment" as const,
        id: payment.id,
        userId: payment.userId,
        userName: payment.user.name,
        title:
          payment.type === PaymentType.RECEIVED
            ? `Payment received from ${payment.party.name}`
            : `Payment paid to ${payment.party.name}`,
        amount: this.decimalString(payment.amount),
        status: payment.type,
        occurredAt: payment.createdAt.toISOString(),
        meta: { party: payment.party, paymentDate: payment.paymentDate },
      })),
      ...expenses.map((expense) => ({
        kind: "expense" as const,
        id: expense.id,
        userId: expense.userId,
        userName: expense.user.name,
        title: `${expense.scope} expense: ${expense.category}`,
        amount: this.decimalString(expense.amount),
        status: expense.scope,
        occurredAt: expense.createdAt.toISOString(),
        meta: { category: expense.category, expenseDate: expense.expenseDate },
      })),
      ...tasks.map((task) => ({
        kind: "task" as const,
        id: task.id,
        userId: task.userId,
        userName: task.user.name,
        title: task.title,
        amount: null,
        status: task.status,
        occurredAt: task.createdAt.toISOString(),
        meta: {
          type: task.type,
          party: task.party,
          scheduledAt: task.scheduledAt,
        },
      })),
      ...callLogs.map((callLog) => ({
        kind: "callLog" as const,
        id: callLog.id,
        userId: callLog.userId,
        userName: callLog.user.name,
        title: callLog.party
          ? `Call logged: ${callLog.party.name}`
          : "Call logged",
        amount: callLog.promisedAmount
          ? this.decimalString(callLog.promisedAmount)
          : null,
        status: callLog.outcome,
        occurredAt: callLog.createdAt.toISOString(),
        meta: {
          party: callLog.party,
          promisedDate: callLog.promisedDate,
          nextFollowup: callLog.nextFollowup,
        },
      })),
      ...aiLogs.map((log) => ({
        kind: "aiParse" as const,
        id: log.id,
        userId: log.userId,
        userName: log.user.name,
        title: log.error ? "AI parse failed" : "AI parse",
        amount: null,
        status: log.error ? "ERROR" : log.confirmed ? "CONFIRMED" : "OPEN",
        occurredAt: log.createdAt.toISOString(),
        meta: {
          rawInput: log.rawInput,
          provider: log.provider,
          model: log.model,
          error: log.error,
        },
      })),
    ];

    return items
      .sort(
        (a, b) =>
          new Date(b.occurredAt).getTime() - new Date(a.occurredAt).getTime(),
      )
      .slice(0, options.take)
      .map((item) => this.serialize(item));
  }

  private aiLogWhere(query: AdminAiLogsQueryDto) {
    const where: Prisma.AiParseLogWhereInput = {
      ...(query.userId ? { userId: query.userId } : {}),
      ...(query.from || query.to
        ? { createdAt: this.dateFilter(query.from, query.to) }
        : {}),
    };

    if (query.status === AdminAiLogStatus.CONFIRMED) {
      where.confirmed = true;
    } else if (query.status === AdminAiLogStatus.UNCONFIRMED) {
      where.confirmed = false;
      where.error = null;
    } else if (query.status === AdminAiLogStatus.ERRORS) {
      where.error = { not: null };
    }

    return where;
  }

  private async exportRecords(query: AdminExportQueryDto) {
    switch (query.table) {
      case AdminExportTable.USERS:
        return this.prisma.user.findMany({
          where: {
            ...(query.from || query.to
              ? { createdAt: this.dateFilter(query.from, query.to) }
              : {}),
          },
          select: {
            id: true,
            name: true,
            businessName: true,
            role: true,
            createdAt: true,
            updatedAt: true,
          },
          orderBy: { createdAt: "desc" },
        });
      case AdminExportTable.PARTIES:
        return this.prisma.party.findMany({
          where: this.exportWhere(query, "createdAt"),
          orderBy: { createdAt: "desc" },
        });
      case AdminExportTable.DEALS:
        return this.prisma.deal.findMany({
          where: this.exportWhere(query, "createdAt"),
          include: {
            party: { select: this.partySelect() },
            items: { orderBy: { sortOrder: "asc" } },
          },
          orderBy: { createdAt: "desc" },
        });
      case AdminExportTable.DEAL_ITEMS:
        return this.prisma.dealItem.findMany({
          where: {
            ...(query.from || query.to
              ? { createdAt: this.dateFilter(query.from, query.to) }
              : {}),
            ...(query.userId ? { deal: { userId: query.userId } } : {}),
          },
          include: {
            deal: {
              select: {
                id: true,
                userId: true,
                partyId: true,
                type: true,
                createdAt: true,
                party: { select: this.partySelect() },
              },
            },
          },
          orderBy: { createdAt: "desc" },
        });
      case AdminExportTable.PAYMENTS:
        return this.prisma.payment.findMany({
          where: this.exportWhere(query, "paymentDate"),
          include: {
            party: { select: this.partySelect() },
            deal: { select: { id: true, type: true, cashewGrade: true } },
          },
          orderBy: { paymentDate: "desc" },
        });
      case AdminExportTable.EXPENSES:
        return this.prisma.expense.findMany({
          where: this.exportWhere(query, "expenseDate"),
          orderBy: { expenseDate: "desc" },
        });
      case AdminExportTable.TASKS:
        return this.prisma.task.findMany({
          where: this.exportWhere(query, "scheduledAt"),
          include: { party: { select: this.partySelect() } },
          orderBy: { scheduledAt: "desc" },
        });
      case AdminExportTable.CALL_LOGS:
        return this.prisma.callLog.findMany({
          where: this.exportWhere(query, "createdAt"),
          include: {
            party: { select: this.partySelect() },
            task: { select: { id: true, title: true, type: true } },
          },
          orderBy: { createdAt: "desc" },
        });
      case AdminExportTable.AI_PARSE_LOGS:
        return this.prisma.aiParseLog.findMany({
          where: this.exportWhere(query, "createdAt"),
          include: {
            user: {
              select: {
                id: true,
                name: true,
                businessName: true,
                role: true,
              },
            },
          },
          orderBy: { createdAt: "desc" },
        });
    }
  }

  private exportWhere(query: AdminExportQueryDto, dateField: string) {
    return {
      ...(query.userId ? { userId: query.userId } : {}),
      ...(query.from || query.to
        ? { [dateField]: this.dateFilter(query.from, query.to) }
        : {}),
    };
  }

  private dateFilter(from?: string, to?: string) {
    return {
      ...(from ? { gte: new Date(`${from}T00:00:00.000Z`) } : {}),
      ...(to ? { lt: this.nextDay(to) } : {}),
    };
  }

  private dayRange(date?: string) {
    const label = date ?? new Date().toISOString().slice(0, 10);
    const start = new Date(`${label}T00:00:00.000Z`);
    const end = new Date(start);
    end.setUTCDate(end.getUTCDate() + 1);
    return { start, end, label };
  }

  private rangeForActivity(range: AdminActivityRange) {
    const today = this.dayRange();
    const start = new Date(today.start);
    if (range === AdminActivityRange.SEVEN_DAYS) {
      start.setUTCDate(start.getUTCDate() - 6);
    } else if (range === AdminActivityRange.THIRTY_DAYS) {
      start.setUTCDate(start.getUTCDate() - 29);
    }
    return { start, end: today.end };
  }

  private nextDay(date: string) {
    const end = new Date(`${date}T00:00:00.000Z`);
    end.setUTCDate(end.getUTCDate() + 1);
    return end;
  }

  private async assertUserExists(id: string) {
    const count = await this.prisma.user.count({ where: { id } });
    if (count === 0) {
      throw new UnauthorizedException("User not found");
    }
  }

  private userSelect() {
    return {
      id: true,
      name: true,
      businessName: true,
      role: true,
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

  private toCsv(records: Record<string, unknown>[]) {
    if (records.length === 0) {
      return "";
    }

    const columns = Array.from(
      records.reduce((set, record) => {
        Object.keys(record).forEach((key) => set.add(key));
        return set;
      }, new Set<string>()),
    );

    const rows = [
      columns.map((column) => this.csvCell(column)).join(","),
      ...records.map((record) =>
        columns
          .map((column) => this.csvCell(this.csvValue(record[column])))
          .join(","),
      ),
    ];

    return rows.join("\n");
  }

  private csvValue(value: unknown) {
    if (value === null || value === undefined) {
      return "";
    }
    if (typeof value === "object") {
      return JSON.stringify(value);
    }
    return String(value);
  }

  private csvCell(value: string) {
    const escaped = value.replace(/"/g, '""');
    return /[",\n\r]/.test(escaped) ? `"${escaped}"` : escaped;
  }

  private serialize(value: unknown): unknown {
    if (value instanceof Date) {
      return value.toISOString();
    }
    if (value instanceof Prisma.Decimal) {
      return value.toFixed(2);
    }
    if (Array.isArray(value)) {
      return value.map((item) => this.serialize(item));
    }
    if (value && typeof value === "object") {
      return Object.fromEntries(
        Object.entries(value as Record<string, unknown>).map(([key, entry]) => [
          key,
          this.serialize(entry),
        ]),
      );
    }
    return value;
  }

  private decimalString(value: Prisma.Decimal | number | string) {
    return new Prisma.Decimal(value).toFixed(2);
  }
}
