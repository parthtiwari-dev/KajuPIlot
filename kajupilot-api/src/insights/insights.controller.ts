import { Controller, Get, Query, UseGuards } from "@nestjs/common";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { InsightsDateQueryDto } from "./insights-query.dto";
import { InsightsService } from "./insights.service";
import { TodayInsightsDto } from "./today-insights.dto";

@Controller("insights")
@UseGuards(JwtAuthGuard)
export class InsightsController {
  constructor(private readonly insightsService: InsightsService) {}

  @Get("today")
  today(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: TodayInsightsDto,
  ) {
    return this.insightsService.today(user, query.date);
  }

  @Get("weekly")
  weekly(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: InsightsDateQueryDto,
  ) {
    return this.insightsService.weekly(user, query.to);
  }

  @Get("people")
  people(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: InsightsDateQueryDto,
  ) {
    return this.insightsService.people(user, query.to);
  }
}
