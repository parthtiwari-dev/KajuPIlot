import { IsEnum, IsOptional, IsString, MaxLength } from "class-validator";
import { PartyType, TrustTag } from "@prisma/client";

export class UpdatePartyDto {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(32)
  phone?: string;

  @IsOptional()
  @IsEnum(PartyType)
  type?: PartyType;

  @IsOptional()
  @IsEnum(TrustTag)
  trustTag?: TrustTag;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;
}
