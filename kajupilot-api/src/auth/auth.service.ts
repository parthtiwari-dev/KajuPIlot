import { Injectable, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { Role } from "@prisma/client";
import { randomUUID } from "crypto";
import { PrismaService } from "../prisma/prisma.service";
import { SetupAuthDto } from "./dto/setup-auth.dto";
import { DeviceTokenPayload } from "./types/device-token-payload";

@Injectable()
export class AuthService {
  constructor(
    private readonly configService: ConfigService,
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
  ) {}

  async setupOwner(dto: SetupAuthDto) {
    const expectedCode = this.configService.get<string>("ADMIN_SETUP_CODE");
    if (!expectedCode || dto.setupCode !== expectedCode) {
      throw new UnauthorizedException("Invalid setup code");
    }

    const existingOwner = await this.prisma.user.findFirst({
      where: { role: "OWNER" },
      orderBy: { createdAt: "asc" },
    });

    if (existingOwner) {
      const deviceToken = await this.ensureJwtDeviceToken(
        existingOwner.id,
        existingOwner.role,
        existingOwner.deviceToken,
      );

      return {
        userId: existingOwner.id,
        deviceToken,
      };
    }

    const userId = randomUUID();
    const deviceToken = await this.issueDeviceToken(userId, Role.OWNER);
    const user = await this.prisma.user.create({
      data: {
        id: userId,
        name: dto.name ?? "Owner",
        businessName: dto.businessName,
        deviceToken,
        role: Role.OWNER,
      },
    });

    return {
      userId: user.id,
      deviceToken: user.deviceToken,
    };
  }

  async getCurrentUser(deviceToken: string) {
    const payload = await this.verifyDeviceToken(deviceToken);
    const user = await this.prisma.user.findFirst({
      where: {
        id: payload.sub,
        deviceToken,
      },
      select: {
        id: true,
        name: true,
        businessName: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException("Invalid device token");
    }

    return user;
  }

  private async ensureJwtDeviceToken(
    userId: string,
    role: Role,
    existingToken: string,
  ) {
    try {
      await this.verifyDeviceToken(existingToken);
      return existingToken;
    } catch {
      const deviceToken = await this.issueDeviceToken(userId, role);
      await this.prisma.user.update({
        where: { id: userId },
        data: { deviceToken },
      });
      return deviceToken;
    }
  }

  private async issueDeviceToken(userId: string, role: Role) {
    const payload: DeviceTokenPayload = {
      sub: userId,
      role,
      typ: "device",
    };

    return this.jwtService.signAsync(payload, {
      secret: this.configService.getOrThrow<string>("JWT_SECRET"),
    });
  }

  private async verifyDeviceToken(deviceToken: string) {
    try {
      const payload = await this.jwtService.verifyAsync<DeviceTokenPayload>(
        deviceToken,
        {
          secret: this.configService.getOrThrow<string>("JWT_SECRET"),
        },
      );

      if (!payload.sub || payload.typ !== "device") {
        throw new UnauthorizedException("Invalid device token");
      }

      return payload;
    } catch {
      throw new UnauthorizedException("Invalid device token");
    }
  }
}
