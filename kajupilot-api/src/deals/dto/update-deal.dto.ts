import {
  ArrayMinSize,
  IsEnum,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
  ValidateNested,
} from "class-validator";
import { Type } from "class-transformer";
import { DealType } from "@prisma/client";
import { DealItemDto } from "./create-deal.dto";

const decimalPattern = /^\d+(\.\d{1,2})?$/;

export class UpdateDealDto {
  @IsOptional()
  @IsUUID()
  partyId?: string;

  @IsOptional()
  @IsEnum(DealType)
  type?: DealType;

  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => DealItemDto)
  @ArrayMinSize(1)
  items?: DealItemDto[];

  @IsOptional()
  @IsString()
  @Matches(decimalPattern)
  totalAmount?: string;

  @IsOptional()
  @IsString()
  @Matches(decimalPattern)
  paidAmount?: string;

  @IsOptional()
  @IsISO8601()
  deliveryDate?: string | null;

  @IsOptional()
  @IsISO8601()
  paymentDue?: string | null;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string | null;
}
