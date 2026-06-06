import { IsEnum, IsISO8601, IsOptional } from "class-validator";
import { ExpenseCategory, ExpenseScope } from "@prisma/client";

export class ListExpensesDto {
  @IsOptional()
  @IsEnum(ExpenseCategory)
  category?: ExpenseCategory;

  @IsOptional()
  @IsEnum(ExpenseScope)
  scope?: ExpenseScope;

  @IsOptional()
  @IsISO8601()
  from?: string;

  @IsOptional()
  @IsISO8601()
  to?: string;
}
