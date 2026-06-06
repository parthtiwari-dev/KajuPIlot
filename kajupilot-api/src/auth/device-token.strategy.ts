import { Injectable, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { PassportStrategy } from "@nestjs/passport";
import { ExtractJwt, Strategy } from "passport-jwt";
import { Request } from "express";
import { PrismaService } from "../prisma/prisma.service";
import { DeviceTokenPayload } from "./types/device-token-payload";

@Injectable()
export class DeviceTokenStrategy extends PassportStrategy(Strategy, "jwt") {
  constructor(
    configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      passReqToCallback: true,
      secretOrKey: configService.getOrThrow<string>("JWT_SECRET"),
    });
  }

  async validate(request: Request, payload: DeviceTokenPayload) {
    if (payload.typ !== "device") {
      throw new UnauthorizedException("Invalid token type");
    }

    const deviceToken = ExtractJwt.fromAuthHeaderAsBearerToken()(request);
    if (!deviceToken) {
      throw new UnauthorizedException("Missing bearer token");
    }

    const user = await this.prisma.user.findFirst({
      where: {
        id: payload.sub,
        deviceToken,
      },
      select: {
        id: true,
        role: true,
        name: true,
        businessName: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException("Invalid device token");
    }

    return user;
  }
}
