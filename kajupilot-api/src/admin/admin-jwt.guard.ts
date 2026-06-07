import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { Role } from "@prisma/client";
import { Request } from "express";

interface AdminTokenPayload {
  sub: string;
  role: Role;
  typ: "admin";
}

@Injectable()
export class AdminJwtGuard implements CanActivate {
  constructor(
    private readonly configService: ConfigService,
    private readonly jwtService: JwtService,
  ) {}

  async canActivate(context: ExecutionContext) {
    const request = context.switchToHttp().getRequest<Request>();
    const token = this.extractBearerToken(request);

    if (!token) {
      throw new UnauthorizedException("Missing admin token");
    }

    try {
      const payload = await this.jwtService.verifyAsync<AdminTokenPayload>(
        token,
        {
          secret: this.configService.getOrThrow<string>("JWT_SECRET"),
        },
      );

      if (payload.typ !== "admin" || payload.role !== Role.ADMIN) {
        throw new UnauthorizedException("Invalid admin token");
      }

      request.user = {
        id: payload.sub,
        role: Role.ADMIN,
        name: payload.sub,
        businessName: null,
      };
      return true;
    } catch {
      throw new UnauthorizedException("Invalid admin token");
    }
  }

  private extractBearerToken(request: Request) {
    const header = request.headers.authorization;
    if (!header) {
      return null;
    }

    const [scheme, token] = header.split(" ");
    return scheme?.toLowerCase() === "bearer" && token ? token : null;
  }
}
