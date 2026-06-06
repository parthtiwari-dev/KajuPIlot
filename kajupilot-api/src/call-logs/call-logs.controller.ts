import { Body, Controller, Get, Post, Query, UseGuards } from "@nestjs/common";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { CallLogsService } from "./call-logs.service";
import { CreateCallLogDto } from "./dto/create-call-log.dto";
import { ListCallLogsDto } from "./dto/list-call-logs.dto";

@Controller("call-logs")
@UseGuards(JwtAuthGuard)
export class CallLogsController {
  constructor(private readonly callLogsService: CallLogsService) {}

  @Get()
  list(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: ListCallLogsDto,
  ) {
    return this.callLogsService.list(user, query);
  }

  @Post()
  create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateCallLogDto,
  ) {
    return this.callLogsService.create(user, dto);
  }
}
