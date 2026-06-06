import {
  IsEnum,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
} from "class-validator";
import { ExpenseCategory, ExpenseScope } from "@prisma/client";

const decimalPattern = /^\d+(\.\d{1,2})?$/;

export class CreateExpenseDto {
  @IsOptional()
  @IsUUID()
  id?: string;

  @IsEnum(ExpenseCategory)
  category!: ExpenseCategory;

  @IsOptional()
  @IsEnum(ExpenseScope)
  scope?: ExpenseScope;

  @IsString()
  @Matches(decimalPattern)
  amount!: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;

  @IsISO8601()
  expenseDate!: string;

  @IsString()
  @MaxLength(120)
  syncId!: string;
}
