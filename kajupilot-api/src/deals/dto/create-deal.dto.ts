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
import { DealStatus, DealType } from "@prisma/client";

const decimalPattern = /^\d+(\.\d{1,2})?$/;

export class DealItemDto {
  @IsOptional()
  @IsUUID()
  id?: string;

  @IsString()
  @MaxLength(80)
  grade!: string;

  @IsString()
  @MaxLength(80)
  quantityText!: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  rateText?: string;

  @IsString()
  @Matches(decimalPattern)
  totalAmount!: string;
}

export class CreateDealDto {
  @IsOptional()
  @IsUUID()
  id?: string;

  @IsUUID()
  partyId!: string;

  @IsOptional()
  @IsEnum(DealType)
  type?: DealType;

  @ValidateNested({ each: true })
  @Type(() => DealItemDto)
  @ArrayMinSize(1)
  items!: DealItemDto[];

  @IsString()
  @Matches(decimalPattern)
  totalAmount!: string;

  @IsOptional()
  @IsString()
  @Matches(decimalPattern)
  paidAmount?: string;

  @IsOptional()
  @IsISO8601()
  deliveryDate?: string;

  @IsOptional()
  @IsISO8601()
  paymentDue?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;

  @IsOptional()
  @IsEnum(DealStatus)
  status?: DealStatus;

  @IsString()
  @MaxLength(120)
  syncId!: string;
}
