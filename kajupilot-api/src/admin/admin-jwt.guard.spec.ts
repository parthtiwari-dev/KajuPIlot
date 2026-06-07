import { ExecutionContext, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { Role } from "@prisma/client";
import { AdminJwtGuard } from "./admin-jwt.guard";

describe("AdminJwtGuard", () => {
  let jwtService: { verifyAsync: jest.Mock };
  let guard: AdminJwtGuard;

  beforeEach(() => {
    jwtService = {
      verifyAsync: jest.fn(),
    };
    const configService = {
      getOrThrow: jest.fn().mockReturnValue("test-secret"),
    };
    guard = new AdminJwtGuard(
      configService as unknown as ConfigService,
      jwtService as unknown as JwtService,
    );
  });

  it("accepts admin tokens and attaches an admin user", async () => {
    const request = {
      headers: { authorization: "Bearer admin-token" },
    };
    jwtService.verifyAsync.mockResolvedValue({
      sub: "parth",
      role: Role.ADMIN,
      typ: "admin",
    });

    await expect(guard.canActivate(contextFor(request))).resolves.toBe(true);

    expect(request).toMatchObject({
      user: {
        id: "parth",
        role: Role.ADMIN,
      },
    });
  });

  it("rejects device tokens", async () => {
    jwtService.verifyAsync.mockResolvedValue({
      sub: "owner-1",
      role: Role.OWNER,
      typ: "device",
    });

    await expect(
      guard.canActivate(
        contextFor({ headers: { authorization: "Bearer device-token" } }),
      ),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it("rejects missing bearer tokens", async () => {
    await expect(
      guard.canActivate(contextFor({ headers: {} })),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });
});

function contextFor(request: Record<string, unknown>) {
  return {
    switchToHttp: () => ({
      getRequest: () => request,
    }),
  } as unknown as ExecutionContext;
}
