import {
  IsEnum,
  IsISO8601,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
} from "class-validator";
import { ExpenseCategory, ExpenseScope } from "@prisma/client";

const decimalPattern = /^\d+(\.\d{1,2})?$/;

export class UpdateExpenseDto {
  @IsOptional()
  @IsEnum(ExpenseCategory)
  category?: ExpenseCategory;

  @IsOptional()
  @IsEnum(ExpenseScope)
  scope?: ExpenseScope;

  @IsOptional()
  @IsString()
  @Matches(decimalPattern)
  amount?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;

  @IsOptional()
  @IsISO8601()
  expenseDate?: string;
}
