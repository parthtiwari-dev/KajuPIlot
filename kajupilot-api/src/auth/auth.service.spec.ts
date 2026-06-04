import { UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { Role } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { AuthService } from "./auth.service";

describe("AuthService", () => {
  let service: AuthService;
  let configService: { get: jest.Mock; getOrThrow: jest.Mock };
  let jwtService: { signAsync: jest.Mock; verifyAsync: jest.Mock };
  let prisma: {
    user: {
      findFirst: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
    };
  };

  beforeEach(() => {
    configService = {
      get: jest.fn((key: string) =>
        key === "ADMIN_SETUP_CODE" ? "KAJU-2026" : undefined,
      ),
      getOrThrow: jest.fn((key: string) => {
        if (key === "JWT_SECRET") {
          return "test-secret";
        }
        throw new Error(`Missing ${key}`);
      }),
    };
    jwtService = {
      signAsync: jest.fn().mockResolvedValue("signed-device-token"),
      verifyAsync: jest.fn(),
    };
    prisma = {
      user: {
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
    };

    service = new AuthService(
      configService as unknown as ConfigService,
      jwtService as unknown as JwtService,
      prisma as unknown as PrismaService,
    );
  });

  it("sets up an owner with a signed device token", async () => {
    prisma.user.findFirst.mockResolvedValueOnce(null);
    prisma.user.create.mockImplementation(async ({ data }) => ({
      ...data,
      createdAt: new Date(),
      updatedAt: new Date(),
    }));

    const result = await service.setupOwner({
      setupCode: "KAJU-2026",
      name: "Vikram",
    });

    expect(result).toEqual({
      userId: expect.any(String),
      deviceToken: "signed-device-token",
    });
    expect(jwtService.signAsync).toHaveBeenCalledWith(
      {
        sub: expect.any(String),
        role: Role.OWNER,
        typ: "device",
      },
      { secret: "test-secret" },
    );
    expect(prisma.user.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        name: "Vikram",
        deviceToken: "signed-device-token",
        role: Role.OWNER,
      }),
    });
  });

  it("rejects setup with a wrong code", async () => {
    await expect(
      service.setupOwner({ setupCode: "WRONG-CODE" }),
    ).rejects.toBeInstanceOf(UnauthorizedException);

    expect(prisma.user.create).not.toHaveBeenCalled();
  });

  it("rejects an invalid device token", async () => {
    jwtService.verifyAsync.mockRejectedValueOnce(new Error("bad token"));

    await expect(service.getCurrentUser("bad-token")).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });
});
