import { Module } from "@nestjs/common";
import { DealsModule } from "../deals/deals.module";
import { ExpensesModule } from "../expenses/expenses.module";
import { InsightsModule } from "../insights/insights.module";
import { PartiesModule } from "../parties/parties.module";
import { PaymentsModule } from "../payments/payments.module";
import { TasksModule } from "../tasks/tasks.module";
import { AiConfigService } from "./ai-config.service";
import { AiParserService } from "./ai-parser.service";
import { AiRateLimitService } from "./ai-rate-limit.service";
import { AiSummaryService } from "./ai-summary.service";
import { AiController } from "./ai.controller";
import { AiService } from "./ai.service";

@Module({
  imports: [
    PartiesModule,
    DealsModule,
    PaymentsModule,
    ExpensesModule,
    TasksModule,
    InsightsModule,
  ],
  controllers: [AiController],
  providers: [
    AiConfigService,
    AiService,
    AiParserService,
    AiRateLimitService,
    AiSummaryService,
  ],
  exports: [AiConfigService, AiService, AiParserService],
})
export class AiModule {}
