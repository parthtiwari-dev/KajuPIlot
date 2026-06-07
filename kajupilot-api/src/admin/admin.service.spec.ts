import { UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { DealType, PaymentType, Prisma, Role } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { AdminService } from "./admin.service";
import {
  AdminAiLogStatus,
  AdminExportFormat,
  AdminExportTable,
} from "./dto/admin-query.dto";

describe("AdminService", () => {
  let service: AdminService;
  let jwtService: { signAsync: jest.Mock };
  let prisma: ReturnType<typeof prismaMock>;

  beforeEach(() => {
    const configService = {
      get: jest.fn((key: string) => {
        if (key === "ADMIN_USER") {
          return "parth";
        }
        if (key === "ADMIN_SECRET") {
          return "secret";
        }
        return undefined;
      }),
      getOrThrow: jest.fn().mockReturnValue("jwt-secret"),
    };
    jwtService = {
      signAsync: jest.fn().mockResolvedValue("admin-jwt"),
    };
    prisma = prismaMock();
    service = new AdminService(
      configService as unknown as ConfigService,
      jwtService as unknown as JwtService,
      prisma as unknown as PrismaService,
    );
  });

  it("issues an admin JWT on valid credentials", async () => {
    const result = await service.login({ username: "parth", secret: "secret" });

    expect(result.adminToken).toBe("admin-jwt");
    expect(jwtService.signAsync).toHaveBeenCalledWith(
      {
        sub: "parth",
        role: Role.ADMIN,
        typ: "admin",
      },
      {
        secret: "jwt-secret",
        expiresIn: "12h",
      },
    );
  });

  it("rejects invalid admin credentials", async () => {
    await expect(
      service.login({ username: "parth", secret: "wrong" }),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it("returns system stats with active users, pending collection, and AI success rate", async () => {
    prisma.deal.count.mockResolvedValue(2);
    prisma.payment.count.mockResolvedValue(4);
    prisma.user.count.mockResolvedValue(3);
    prisma.aiParseLog.count
      .mockResolvedValueOnce(5)
      .mockResolvedValueOnce(3)
      .mockResolvedValueOnce(1);

    prisma.deal.findMany.mockResolvedValueOnce([{ userId: "user-1" }]);
    prisma.payment.findMany.mockResolvedValueOnce([{ userId: "user-1" }]);
    prisma.expense.findMany.mockResolvedValueOnce([]);
    prisma.task.findMany.mockResolvedValueOnce([]);
    prisma.callLog.findMany.mockResolvedValueOnce([{ userId: "user-2" }]);
    prisma.aiParseLog.findMany.mockResolvedValueOnce([]);

    prisma.party.findMany.mockResolvedValue([
      {
        deals: [
          {
            type: DealType.SALE,
            totalAmount: new Prisma.Decimal("1000.00"),
            paidAmount: new Prisma.Decimal("200.00"),
          },
        ],
        payments: [
          {
            type: PaymentType.RECEIVED,
            amount: new Prisma.Decimal("100.00"),
          },
        ],
      },
    ]);

    prisma.deal.findMany.mockResolvedValueOnce([]);
    prisma.payment.findMany.mockResolvedValueOnce([]);
    prisma.expense.findMany.mockResolvedValueOnce([]);
    prisma.task.findMany.mockResolvedValueOnce([]);
    prisma.callLog.findMany.mockResolvedValueOnce([]);
    prisma.aiParseLog.findMany.mockResolvedValueOnce([]);

    const result = await service.stats({ date: "2026-06-07" });

    expect(result).toMatchObject({
      activeUsers: 2,
      totalUsers: 3,
      dealsCreated: 2,
      paymentsLogged: 4,
      pendingCollection: "700.00",
      aiParse: {
        total: 5,
        confirmed: 3,
        errors: 1,
        unconfirmed: 1,
        successRate: 60,
      },
    });
  });

  it("filters AI logs by error status and paginates", async () => {
    prisma.aiParseLog.count.mockResolvedValue(1);
    prisma.aiParseLog.findMany.mockResolvedValue([
      {
        id: "log-1",
        userId: "user-1",
        rawInput: "bad json",
        parsedJson: {},
        confirmed: false,
        error: "parse_failed",
        provider: "openai",
        model: "gpt-4o-mini",
        usageJson: null,
        confirmedAt: null,
        confirmedJson: null,
        createdAt: new Date("2026-06-07T10:00:00.000Z"),
        user: {
          id: "user-1",
          name: "Owner",
          businessName: null,
          role: Role.OWNER,
        },
      },
    ]);

    const result = await service.aiLogs({
      status: AdminAiLogStatus.ERRORS,
      page: 2,
    });

    expect(prisma.aiParseLog.count).toHaveBeenCalledWith({
      where: { error: { not: null } },
    });
    expect(prisma.aiParseLog.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        skip: 25,
        take: 25,
      }),
    );
    const items = result.items as Record<string, unknown>[];
    expect(items[0]).toMatchObject({
      id: "log-1",
      error: "parse_failed",
    });
  });

  it("exports users without device tokens", async () => {
    prisma.user.findMany.mockResolvedValue([
      {
        id: "user-1",
        name: "Owner",
        businessName: "Kaju",
        role: Role.OWNER,
        createdAt: new Date("2026-06-07T10:00:00.000Z"),
        updatedAt: new Date("2026-06-07T10:00:00.000Z"),
      },
    ]);

    const result = await service.exportData({
      table: AdminExportTable.USERS,
      format: AdminExportFormat.JSON,
    });

    expect(prisma.user.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        select: expect.not.objectContaining({ deviceToken: true }),
      }),
    );
    expect(result.body).not.toContain("deviceToken");
    expect(result.contentType).toContain("application/json");
  });
});

function prismaMock() {
  return {
    user: {
      count: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
    party: {
      findMany: jest.fn(),
    },
    deal: {
      count: jest.fn(),
      findMany: jest.fn(),
    },
    dealItem: {
      findMany: jest.fn(),
    },
    payment: {
      count: jest.fn(),
      findMany: jest.fn(),
    },
    expense: {
      findMany: jest.fn(),
    },
    task: {
      findMany: jest.fn(),
    },
    callLog: {
      findMany: jest.fn(),
    },
    aiParseLog: {
      count: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
  };
}
