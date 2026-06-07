import { Type } from "class-transformer";
import {
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from "class-validator";

const itemKinds = ["task", "deal", "payment", "expense"] as const;

export class ConfirmDealLineItemDto {
  @IsString()
  @MaxLength(80)
  grade!: string;

  @IsString()
  @MaxLength(80)
  quantityText!: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  rateText?: string | null;

  @IsInt()
  @Min(0)
  totalPaise!: number;
}

export class ConfirmParsedItemDto {
  @IsIn(itemKinds)
  kind!: (typeof itemKinds)[number];

  @IsOptional()
  @IsString()
  @MaxLength(80)
  tempId?: string;

  @IsOptional()
  @IsUUID()
  partyId?: string | null;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  partyName?: string | null;

  @IsOptional()
  @IsString()
  @MaxLength(40)
  type?: string;

  @IsOptional()
  @IsString()
  @MaxLength(160)
  title?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string | null;

  @IsOptional()
  @IsISO8601()
  scheduledAt?: string | null;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  priority?: number;

  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => ConfirmDealLineItemDto)
  @IsArray()
  items?: ConfirmDealLineItemDto[];

  @IsOptional()
  @IsInt()
  @Min(0)
  totalPaise?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  paidPaise?: number;

  @IsOptional()
  @IsISO8601()
  deliveryDate?: string | null;

  @IsOptional()
  @IsISO8601()
  paymentDue?: string | null;

  @IsOptional()
  @IsInt()
  @Min(0)
  amountPaise?: number;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  method?: string | null;

  @IsOptional()
  @IsISO8601()
  paymentDate?: string | null;

  @IsOptional()
  @IsString()
  @MaxLength(40)
  category?: string;

  @IsOptional()
  @IsString()
  @MaxLength(40)
  scope?: string;

  @IsOptional()
  @IsISO8601()
  expenseDate?: string | null;

  @IsOptional()
  @IsBoolean()
  needsReview?: boolean;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  warnings?: string[];
}

export class ConfirmAiParseDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ConfirmParsedItemDto)
  items!: ConfirmParsedItemDto[];
}
