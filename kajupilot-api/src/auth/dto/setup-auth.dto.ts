import { IsOptional, IsString, MinLength } from 'class-validator';

export class SetupAuthDto {
  @IsString()
  @MinLength(4)
  setupCode!: string;

  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  businessName?: string;
}
