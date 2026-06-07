import { Body, Controller, Get, Param, Post, UseGuards } from "@nestjs/common";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { AiParserService } from "./ai-parser.service";
import { AiService } from "./ai.service";
import { ConfirmAiParseDto } from "./dto/confirm-ai-parse.dto";
import { ParseAiDto } from "./dto/parse-ai.dto";

@Controller("ai")
export class AiController {
  constructor(
    private readonly aiService: AiService,
    private readonly aiParser: AiParserService,
  ) {}

  @Get("providers")
  providers() {
    return this.aiService.getProviderSummary();
  }

  @UseGuards(JwtAuthGuard)
  @Post("parse")
  parse(@CurrentUser() user: AuthenticatedUser, @Body() dto: ParseAiDto) {
    return this.aiParser.parse(user, dto);
  }

  @UseGuards(JwtAuthGuard)
  @Post("parse/:logId/confirm")
  confirm(
    @CurrentUser() user: AuthenticatedUser,
    @Param("logId") logId: string,
    @Body() dto: ConfirmAiParseDto,
  ) {
    return this.aiParser.confirm(user, logId, dto);
  }
}
