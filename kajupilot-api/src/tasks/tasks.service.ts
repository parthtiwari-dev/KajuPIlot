import {
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from "@nestjs/common";
import { Party, Prisma, Task, TaskStatus } from "@prisma/client";
import { randomUUID } from "crypto";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { PrismaService } from "../prisma/prisma.service";
import { CreateTaskDto } from "./dto/create-task.dto";
import { ListTasksDto } from "./dto/list-tasks.dto";
import { UpdateTaskDto } from "./dto/update-task.dto";

type TaskWithParty = Task & {
  party: Pick<Party, "id" | "name" | "phone" | "type" | "trustTag"> | null;
};

@Injectable()
export class TasksService {
  constructor(private readonly prisma: PrismaService) {}

  async list(user: AuthenticatedUser, query: ListTasksDto) {
    const tasks = await this.prisma.task.findMany({
      where: {
        userId: user.id,
        deletedAt: null,
        ...(query.status ? { status: query.status } : {}),
        ...(query.type ? { type: query.type } : {}),
        ...(query.partyId ? { partyId: query.partyId } : {}),
        ...(query.from || query.to
          ? {
              scheduledAt: {
                ...(query.from ? { gte: new Date(query.from) } : {}),
                ...(query.to ? { lte: new Date(query.to) } : {}),
              },
            }
          : {}),
      },
      include: this.taskInclude(),
      orderBy: [{ scheduledAt: "asc" }, { priority: "desc" }],
    });

    return tasks.map((task) => this.toJson(task));
  }

  async today(user: AuthenticatedUser, date?: string) {
    const { end } = this.dayRange(date);
    const tasks = await this.prisma.task.findMany({
      where: {
        userId: user.id,
        deletedAt: null,
        status: { in: [TaskStatus.PENDING, TaskStatus.POSTPONED] },
        scheduledAt: { lt: end },
      },
      include: this.taskInclude(),
    });

    return tasks
      .sort((a, b) => this.todaySort(a, b))
      .map((task) => this.toJson(task));
  }

  async create(user: AuthenticatedUser, dto: CreateTaskDto) {
    const existing = await this.prisma.task.findUnique({
      where: { syncId: dto.syncId },
      include: this.taskInclude(),
    });

    if (existing) {
      if (existing.userId !== user.id) {
        throw new UnauthorizedException("Invalid sync id");
      }

      if (existing.deletedAt) {
        if (dto.partyId) {
          await this.findActiveParty(user.id, dto.partyId);
        }

        const restored = await this.prisma.task.update({
          where: { id: existing.id },
          data: {
            ...this.createData(user.id, dto),
            deletedAt: null,
          },
          include: this.taskInclude(),
        });
        return this.toJson(restored);
      }

      return this.toJson(existing);
    }

    if (dto.partyId) {
      await this.findActiveParty(user.id, dto.partyId);
    }

    const task = await this.prisma.task.create({
      data: {
        id: dto.id ?? randomUUID(),
        ...this.createData(user.id, dto),
      },
      include: this.taskInclude(),
    });

    return this.toJson(task);
  }

  async update(user: AuthenticatedUser, id: string, dto: UpdateTaskDto) {
    await this.findActiveTask(user.id, id);
    if (dto.partyId) {
      await this.findActiveParty(user.id, dto.partyId);
    }

    const task = await this.prisma.task.update({
      where: { id },
      data: {
        ...(dto.partyId !== undefined ? { partyId: dto.partyId ?? null } : {}),
        ...(dto.type !== undefined ? { type: dto.type } : {}),
        ...(dto.title !== undefined ? { title: dto.title.trim() } : {}),
        ...(dto.notes !== undefined
          ? { notes: this.cleanNullable(dto.notes) }
          : {}),
        ...(dto.scheduledAt !== undefined
          ? { scheduledAt: new Date(dto.scheduledAt) }
          : {}),
        ...(dto.status !== undefined ? { status: dto.status } : {}),
        ...(dto.priority !== undefined ? { priority: dto.priority } : {}),
      },
      include: this.taskInclude(),
    });

    return this.toJson(task);
  }

  async complete(user: AuthenticatedUser, id: string) {
    await this.findActiveTask(user.id, id);
    const task = await this.prisma.task.update({
      where: { id },
      data: {
        status: TaskStatus.DONE,
        completedAt: new Date(),
      },
      include: this.taskInclude(),
    });

    return this.toJson(task);
  }

  async postpone(user: AuthenticatedUser, id: string, scheduledAt: string) {
    await this.findActiveTask(user.id, id);
    const task = await this.prisma.task.update({
      where: { id },
      data: {
        status: TaskStatus.POSTPONED,
        scheduledAt: new Date(scheduledAt),
        completedAt: null,
      },
      include: this.taskInclude(),
    });

    return this.toJson(task);
  }

  async remove(user: AuthenticatedUser, id: string) {
    await this.findActiveTask(user.id, id);
    const task = await this.prisma.task.update({
      where: { id },
      data: { deletedAt: new Date() },
      include: this.taskInclude(),
    });

    return this.toJson(task);
  }

  private createData(userId: string, dto: CreateTaskDto) {
    return {
      userId,
      partyId: dto.partyId ?? null,
      type: dto.type,
      title: dto.title.trim(),
      notes: this.cleanNullable(dto.notes),
      scheduledAt: new Date(dto.scheduledAt),
      priority: dto.priority ?? 0,
      syncId: dto.syncId,
    };
  }

  private async findActiveTask(userId: string, id: string) {
    const task = await this.prisma.task.findFirst({
      where: { id, userId, deletedAt: null },
      include: this.taskInclude(),
    });

    if (!task) {
      throw new NotFoundException("Task not found");
    }

    return task;
  }

  private async findActiveParty(userId: string, id: string) {
    const party = await this.prisma.party.findFirst({
      where: { id, userId, deletedAt: null },
    });

    if (!party) {
      throw new NotFoundException("Party not found");
    }

    return party;
  }

  private todaySort(a: Task, b: Task) {
    const now = new Date();
    const aOverdue = a.scheduledAt < now ? 1 : 0;
    const bOverdue = b.scheduledAt < now ? 1 : 0;
    if (aOverdue !== bOverdue) {
      return bOverdue - aOverdue;
    }
    if (a.priority !== b.priority) {
      return b.priority - a.priority;
    }
    return a.scheduledAt.getTime() - b.scheduledAt.getTime();
  }

  private dayRange(date?: string) {
    const start = date ? new Date(`${date}T00:00:00.000Z`) : new Date();
    start.setUTCHours(0, 0, 0, 0);
    const end = new Date(start);
    end.setUTCDate(end.getUTCDate() + 1);
    return { start, end };
  }

  private taskInclude() {
    return {
      party: { select: this.partySelect() },
    } as const;
  }

  private partySelect() {
    return {
      id: true,
      name: true,
      phone: true,
      type: true,
      trustTag: true,
    } as const;
  }

  private toJson(task: TaskWithParty) {
    return {
      id: task.id,
      userId: task.userId,
      partyId: task.partyId,
      type: task.type,
      title: task.title,
      notes: task.notes,
      scheduledAt: task.scheduledAt.toISOString(),
      completedAt: task.completedAt?.toISOString() ?? null,
      status: task.status,
      priority: task.priority,
      syncId: task.syncId,
      createdAt: task.createdAt.toISOString(),
      updatedAt: task.updatedAt.toISOString(),
      deletedAt: task.deletedAt?.toISOString() ?? null,
      party: task.party
        ? {
            id: task.party.id,
            name: task.party.name,
            phone: task.party.phone,
            type: task.party.type,
            trustTag: task.party.trustTag,
          }
        : null,
    };
  }

  private cleanNullable(value?: string | null) {
    const trimmed = value?.trim();
    return trimmed ? trimmed : null;
  }
}
