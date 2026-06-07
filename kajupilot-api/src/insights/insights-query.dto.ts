import { IsDateString, IsOptional } from "class-validator";

export class InsightsDateQueryDto {
  @IsOptional()
  @IsDateString()
  to?: string;
}
