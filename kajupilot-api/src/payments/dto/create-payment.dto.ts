import {
  IsEnum,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
} from "class-validator";
import { PaymentType } from "@prisma/client";

const decimalPattern = /^\d+(\.\d{1,2})?$/;

export class CreatePaymentDto {
  @IsOptional()
  @IsUUID()
  id?: string;

  @IsUUID()
  partyId!: string;

  @IsOptional()
  @IsUUID()
  dealId?: string | null;

  @IsEnum(PaymentType)
  type!: PaymentType;

  @IsString()
  @Matches(decimalPattern)
  amount!: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  method?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;

  @IsISO8601()
  paymentDate!: string;

  @IsString()
  @MaxLength(120)
  syncId!: string;
}
