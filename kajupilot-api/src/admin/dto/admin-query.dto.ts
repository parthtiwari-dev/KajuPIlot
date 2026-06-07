import { Type } from "class-transformer";
import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Min,
} from "class-validator";

export enum AdminActivityRange {
  TODAY = "today",
  SEVEN_DAYS = "7d",
  THIRTY_DAYS = "30d",
}

export enum AdminAiLogStatus {
  ALL = "all",
  CONFIRMED = "confirmed",
  UNCONFIRMED = "unconfirmed",
  ERRORS = "errors",
}

export enum AdminExportFormat {
  JSON = "json",
  CSV = "csv",
}

export enum AdminExportTable {
  USERS = "users",
  PARTIES = "parties",
  DEALS = "deals",
  DEAL_ITEMS = "dealItems",
  PAYMENTS = "payments",
  EXPENSES = "expenses",
  TASKS = "tasks",
  CALL_LOGS = "callLogs",
  AI_PARSE_LOGS = "aiParseLogs",
}

export class AdminStatsQueryDto {
  @IsOptional()
  @IsDateString()
  date?: string;
}

export class AdminActivityQueryDto {
  @IsOptional()
  @IsEnum(AdminActivityRange)
  range?: AdminActivityRange;
}

export class AdminAiLogsQueryDto {
  @IsOptional()
  @IsString()
  userId?: string;

  @IsOptional()
  @IsEnum(AdminAiLogStatus)
  status?: AdminAiLogStatus;

  @IsOptional()
  @IsDateString()
  from?: string;

  @IsOptional()
  @IsDateString()
  to?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;
}

export class AdminExportQueryDto {
  @IsOptional()
  @IsString()
  userId?: string;

  @IsEnum(AdminExportTable)
  table!: AdminExportTable;

  @IsOptional()
  @IsDateString()
  from?: string;

  @IsOptional()
  @IsDateString()
  to?: string;

  @IsEnum(AdminExportFormat)
  format!: AdminExportFormat;
}
