import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Query,
  UseGuards,
} from "@nestjs/common";
import { CurrentUser } from "../auth/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { CreatePartyDto } from "./dto/create-party.dto";
import { ListPartiesDto } from "./dto/list-parties.dto";
import { UpdatePartyDto } from "./dto/update-party.dto";
import { PartiesService } from "./parties.service";

@Controller("parties")
@UseGuards(JwtAuthGuard)
export class PartiesController {
  constructor(private readonly partiesService: PartiesService) {}

  @Get()
  list(@CurrentUser() user: AuthenticatedUser, @Query() query: ListPartiesDto) {
    return this.partiesService.list(user, query);
  }

  @Post()
  create(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreatePartyDto) {
    return this.partiesService.create(user, dto);
  }

  @Get(":id")
  get(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    return this.partiesService.get(user, id);
  }

  @Put(":id")
  update(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: UpdatePartyDto,
  ) {
    return this.partiesService.update(user, id, dto);
  }

  @Delete(":id")
  remove(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    return this.partiesService.remove(user, id);
  }

  @Get(":id/ledger")
  ledger(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    return this.partiesService.ledger(user, id);
  }

  @Get(":id/history")
  history(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    return this.partiesService.history(user, id);
  }
}
