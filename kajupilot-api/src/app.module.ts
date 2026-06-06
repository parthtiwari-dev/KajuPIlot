import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { AiModule } from "./ai/ai.module";
import { AuthModule } from "./auth/auth.module";
import { DealsModule } from "./deals/deals.module";
import { HealthModule } from "./health/health.module";
import { PartiesModule } from "./parties/parties.module";
import { PrismaModule } from "./prisma/prisma.module";

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
  ],
})
export class AppModule {}
