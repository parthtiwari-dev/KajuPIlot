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
import { CreateTaskDto } from "./dto/create-task.dto";
import { ListTasksDto } from "./dto/list-tasks.dto";
import { PostponeTaskDto } from "./dto/postpone-task.dto";
import { TodayTasksDto } from "./dto/today-tasks.dto";
import { UpdateTaskDto } from "./dto/update-task.dto";
import { TasksService } from "./tasks.service";

@Controller("tasks")
@UseGuards(JwtAuthGuard)
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  @Get()
  list(@CurrentUser() user: AuthenticatedUser, @Query() query: ListTasksDto) {
    return this.tasksService.list(user, query);
  }

  @Get("today")
  today(@CurrentUser() user: AuthenticatedUser, @Query() query: TodayTasksDto) {
    return this.tasksService.today(user, query.date);
  }

  @Post()
  create(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateTaskDto) {
    return this.tasksService.create(user, dto);
  }

  @Put(":id")
  update(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: UpdateTaskDto,
  ) {
    return this.tasksService.update(user, id, dto);
  }

  @Put(":id/complete")
  complete(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    return this.tasksService.complete(user, id);
  }

  @Put(":id/postpone")
  postpone(
    @CurrentUser() user: AuthenticatedUser,
    @Param("id") id: string,
    @Body() dto: PostponeTaskDto,
  ) {
    return this.tasksService.postpone(user, id, dto.scheduledAt);
  }

  @Delete(":id")
  remove(@CurrentUser() user: AuthenticatedUser, @Param("id") id: string) {
    return this.tasksService.remove(user, id);
  }
}
