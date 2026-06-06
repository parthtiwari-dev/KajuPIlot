import { IsEnum } from "class-validator";
import { DealStatus } from "@prisma/client";

export class UpdateDealStatusDto {
  @IsEnum(DealStatus)
  status!: DealStatus;
}
