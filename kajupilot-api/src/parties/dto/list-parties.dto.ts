import { IsEnum, IsOptional, IsString, MaxLength } from "class-validator";
import { PartyType, TrustTag } from "@prisma/client";

export class ListPartiesDto {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  search?: string;

  @IsOptional()
  @IsEnum(PartyType)
  type?: PartyType;

  @IsOptional()
  @IsEnum(TrustTag)
  trustTag?: TrustTag;
}
