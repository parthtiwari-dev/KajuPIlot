import { IsDateString, IsOptional } from "class-validator";

export class TodayTasksDto {
  @IsOptional()
  @IsDateString()
  date?: string;
}
