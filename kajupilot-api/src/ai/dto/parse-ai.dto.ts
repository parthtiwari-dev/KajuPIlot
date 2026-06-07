import { IsDateString, IsOptional, IsString, MaxLength } from "class-validator";

export class ParseAiDto {
  @IsString()
  @MaxLength(5000)
  text!: string;

  @IsDateString()
  localDate!: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  timezone?: string;
}
