import { IsISO8601 } from "class-validator";

export class PostponeTaskDto {
  @IsISO8601()
  scheduledAt!: string;
}
