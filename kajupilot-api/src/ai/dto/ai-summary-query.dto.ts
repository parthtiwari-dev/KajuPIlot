import { IsDateString, IsIn, IsOptional } from "class-validator";

export class AiTodaySummaryQueryDto {
  @IsOptional()
  @IsDateString()
  date?: string;

  @IsOptional()
  @IsIn(["true", "false"])
  refresh?: string;
}

export class AiWeeklySummaryQueryDto {
  @IsOptional()
  @IsDateString()
  to?: string;

  @IsOptional()
  @IsIn(["true", "false"])
  refresh?: string;
}
