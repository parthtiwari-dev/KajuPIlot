import { IsEnum, IsISO8601, IsOptional, IsUUID } from "class-validator";
import { PaymentType } from "@prisma/client";

export class ListPaymentsDto {
  @IsOptional()
  @IsUUID()
  partyId?: string;

  @IsOptional()
  @IsUUID()
  dealId?: string;

  @IsOptional()
  @IsEnum(PaymentType)
  type?: PaymentType;

  @IsOptional()
  @IsISO8601()
  from?: string;

  @IsOptional()
  @IsISO8601()
  to?: string;
}
