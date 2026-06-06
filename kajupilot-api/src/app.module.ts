import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { AiModule } from "./ai/ai.module";
import { AuthModule } from "./auth/auth.module";
import { CallLogsModule } from "./call-logs/call-logs.module";
import { DealsModule } from "./deals/deals.module";
import { ExpensesModule } from "./expenses/expenses.module";
import { HealthModule } from "./health/health.module";
import { InsightsModule } from "./insights/insights.module";
import { PartiesModule } from "./parties/parties.module";
import { PaymentsModule } from "./payments/payments.module";
import { PrismaModule } from "./prisma/prisma.module";
import { TasksModule } from "./tasks/tasks.module";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    PrismaModule,
    HealthModule,
    AuthModule,
    AiModule,
    PartiesModule,
    DealsModule,
    PaymentsModule,
    ExpensesModule,
    TasksModule,
    CallLogsModule,
    InsightsModule,
  ],
})
export class AppModule {}
