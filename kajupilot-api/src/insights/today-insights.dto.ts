import { IsDateString, IsOptional } from "class-validator";

export class TodayInsightsDto {
  @IsOptional()
  @IsDateString()
  date?: string;
}
