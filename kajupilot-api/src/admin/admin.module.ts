import { Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { JwtModule } from "@nestjs/jwt";
import { RolesGuard } from "../auth/roles.guard";
import { PrismaModule } from "../prisma/prisma.module";
import { AdminAuthController, AdminController } from "./admin.controller";
import { AdminJwtGuard } from "./admin-jwt.guard";
import { AdminService } from "./admin.service";

@Module({
  imports: [
    PrismaModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.getOrThrow<string>("JWT_SECRET"),
      }),
    }),
  ],
  controllers: [AdminAuthController, AdminController],
  providers: [AdminService, AdminJwtGuard, RolesGuard],
})
export class AdminModule {}
