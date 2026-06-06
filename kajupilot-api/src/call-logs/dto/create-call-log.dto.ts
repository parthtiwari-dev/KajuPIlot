import { Type } from "class-transformer";
import {
  IsEnum,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
  ValidateNested,
} from "class-validator";
import { CallOutcome } from "@prisma/client";

const decimalPattern = /^\d+(\.\d{1,2})?$/;

export class FollowUpTaskDto {
  @IsOptional()
  @IsUUID()
  id?: string;

  @IsString()
  @MaxLength(120)
  syncId!: string;

  @IsOptional()
  @IsISO8601()
  scheduledAt?: string;

  @IsOptional()
  @IsString()
  @MaxLength(160)
  title?: string;
}

export class CreateCallLogDto {
  @IsOptional()
  @IsUUID()
  id?: string;

  @IsOptional()
  @IsUUID()
  taskId?: string | null;

  @IsOptional()
  @IsUUID()
  partyId?: string | null;

  @IsEnum(CallOutcome)
  outcome!: CallOutcome;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string | null;

  @IsOptional()
  @IsISO8601()
  promisedDate?: string | null;

  @IsOptional()
  @IsString()
  @Matches(decimalPattern)
  promisedAmount?: string | null;

  @IsOptional()
  @ValidateNested()
  @Type(() => FollowUpTaskDto)
  followUpTask?: FollowUpTaskDto;

  @IsString()
  @MaxLength(120)
  syncId!: string;
}
