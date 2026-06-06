import { Module } from "@nestjs/common";
import { AiConfigService } from "./ai-config.service";
import { AiController } from "./ai.controller";
import { AiService } from "./ai.service";

@Module({
  controllers: [AiController],
  providers: [AiConfigService, AiService],
  exports: [AiConfigService, AiService],
})
export class AiModule {}
