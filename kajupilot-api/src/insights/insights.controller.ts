import { Controller, Get, Query, UseGuards } from "@nestjs/common";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
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
}
