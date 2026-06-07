import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  Res,
  UseGuards,
} from "@nestjs/common";
import { Role } from "@prisma/client";
import { Response } from "express";
import { Roles } from "../auth/roles.decorator";
import { RolesGuard } from "../auth/roles.guard";
import { AdminJwtGuard } from "./admin-jwt.guard";
import { AdminService } from "./admin.service";
import { AdminLoginDto } from "./dto/admin-login.dto";
import {
  AdminActivityQueryDto,
  AdminAiLogsQueryDto,
  AdminExportQueryDto,
  AdminStatsQueryDto,
} from "./dto/admin-query.dto";

@Controller("admin/auth")
export class AdminAuthController {
  constructor(private readonly adminService: AdminService) {}

  @Post("login")
  login(@Body() dto: AdminLoginDto) {
    return this.adminService.login(dto);
  }
}

@Controller("admin")
@UseGuards(AdminJwtGuard, RolesGuard)
@Roles(Role.ADMIN)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get("stats")
  stats(@Query() query: AdminStatsQueryDto) {
    return this.adminService.stats(query);
  }

  @Get("users")
  users() {
    return this.adminService.users();
  }

  @Get("users/:id/activity")
  userActivity(@Param("id") id: string, @Query() query: AdminActivityQueryDto) {
    return this.adminService.userActivity(id, query);
  }

  @Get("users/:id")
  user(@Param("id") id: string) {
    return this.adminService.user(id);
  }

  @Get("ai-logs")
  aiLogs(@Query() query: AdminAiLogsQueryDto) {
    return this.adminService.aiLogs(query);
  }

  @Get("ai-logs/:id")
  aiLog(@Param("id") id: string) {
    return this.adminService.aiLog(id);
  }

  @Get("exports")
  async export(
    @Query() query: AdminExportQueryDto,
    @Res({ passthrough: true }) response: Response,
  ) {
    const result = await this.adminService.exportData(query);
    response.setHeader("Content-Type", result.contentType);
    response.setHeader(
      "Content-Disposition",
      `attachment; filename="${result.filename}"`,
    );
    return result.body;
  }
}
