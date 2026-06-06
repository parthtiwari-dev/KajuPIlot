import { Module } from "@nestjs/common";
import { PrismaModule } from "../prisma/prisma.module";
import { CallLogsController } from "./call-logs.controller";
import { CallLogsService } from "./call-logs.service";

@Module({
  imports: [PrismaModule],
  controllers: [CallLogsController],
  providers: [CallLogsService],
  exports: [CallLogsService],
})
export class CallLogsModule {}
