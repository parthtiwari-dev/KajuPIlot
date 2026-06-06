import { UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { Role } from "@prisma/client";
import { Request } from "express";
import { PrismaService } from "../prisma/prisma.service";
import { DeviceTokenStrategy } from "./device-token.strategy";
import { DeviceTokenPayload } from "./types/device-token-payload";

describe("DeviceTokenStrategy", () => {
  let strategy: DeviceTokenStrategy;
  let prisma: {
    user: {
      findFirst: jest.Mock;
    };
  };

  beforeEach(() => {
    const configService = {
      getOrThrow: jest.fn((key: string) => {
        if (key === "JWT_SECRET") {
          return "test-secret";
        }
        throw new Error(`Missing ${key}`);
      }),
    };

    prisma = {
      user: {
        findFirst: jest.fn(),
      },
    };

    strategy = new DeviceTokenStrategy(
      configService as unknown as ConfigService,
      prisma as unknown as PrismaService,
    );
  });

  it("rejects a missing bearer token", async () => {
    await expect(
      strategy.validate(requestWithAuth(), payload()),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it("returns the current user when token and payload match", async () => {
    const user = {
      id: "user-1",
      role: Role.OWNER,
      name: "Owner",
      businessName: null,
    };
    prisma.user.findFirst.mockResolvedValueOnce(user);

    await expect(
      strategy.validate(requestWithAuth("Bearer signed-token"), payload()),
    ).resolves.toEqual(user);
    expect(prisma.user.findFirst).toHaveBeenCalledWith({
      where: {
        id: "user-1",
        deviceToken: "signed-token",
      },
      select: {
        id: true,
        role: true,
        name: true,
        businessName: true,
      },
    });
  });

  it("rejects a token that is not stored for the user", async () => {
    prisma.user.findFirst.mockResolvedValueOnce(null);

    await expect(
      strategy.validate(requestWithAuth("Bearer stale-token"), payload()),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });
});

function payload(
  overrides: Partial<DeviceTokenPayload> = {},
): DeviceTokenPayload {
  return {
    sub: "user-1",
    role: Role.OWNER,
    typ: "device",
    ...overrides,
  };
}

function requestWithAuth(authorization?: string): Request {
  return {
    headers: authorization ? { authorization } : {},
  } as Request;
}
