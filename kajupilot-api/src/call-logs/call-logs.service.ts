import {
  BadRequestException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from "@nestjs/common";
import {
  CallLog,
  CallOutcome,
  Party,
  Prisma,
  Task,
  TaskStatus,
  TaskType,
} from "@prisma/client";
import { randomUUID } from "crypto";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { PrismaService } from "../prisma/prisma.service";
import { CreateCallLogDto, FollowUpTaskDto } from "./dto/create-call-log.dto";
import { ListCallLogsDto } from "./dto/list-call-logs.dto";

type CallLogWithRelations = CallLog & {
  party: Pick<Party, "id" | "name" | "phone" | "type" | "trustTag"> | null;
  task: Pick<Task, "id" | "type" | "title" | "scheduledAt" | "status"> | null;
};

type TaskWithParty = Task & {
  party: Pick<Party, "id" | "name" | "phone" | "type" | "trustTag"> | null;
};

@Injectable()
export class CallLogsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(user: AuthenticatedUser, query: ListCallLogsDto) {
    const callLogs = await this.prisma.callLog.findMany({
      where: {
        userId: user.id,
        ...(query.partyId ? { partyId: query.partyId } : {}),
        ...(query.from || query.to
          ? {
              createdAt: {
                ...(query.from ? { gte: new Date(query.from) } : {}),
                ...(query.to ? { lte: new Date(query.to) } : {}),
              },
            }
          : {}),
      },
      include: this.callLogInclude(),
      orderBy: { createdAt: "desc" },
    });

    return callLogs.map((callLog) => this.toJson(callLog));
  }

  async create(user: AuthenticatedUser, dto: CreateCallLogDto) {
    const existing = await this.prisma.callLog.findUnique({
      where: { syncId: dto.syncId },
      include: this.callLogInclude(),
    });

    if (existing) {
      if (existing.userId !== user.id) {
        throw new UnauthorizedException("Invalid sync id");
      }
      return this.toJson(existing);
    }

    const task = dto.taskId
      ? await this.findActiveTask(user.id, dto.taskId)
      : null;
    const partyId = dto.partyId ?? task?.partyId ?? null;
    const party = partyId ? await this.findActiveParty(user.id, partyId) : null;
    this.assertOutcome(dto);

    const result = await this.prisma.$transaction(async (tx) => {
      let nextTask: TaskWithParty | null = null;
      const nextFollowup = this.nextFollowupAt(dto, task);

      if (nextFollowup) {
        nextTask = await this.createFollowUpTask(
          tx,
          user.id,
          dto,
          party,
          task,
          nextFollowup,
        );
      }

      const callLog = await tx.callLog.create({
        data: {
          id: dto.id ?? randomUUID(),
          userId: user.id,
          taskId: dto.taskId ?? null,
          partyId,
          outcome: dto.outcome,
          notes: this.cleanNullable(dto.notes),
          promisedDate: this.optionalDate(dto.promisedDate),
          promisedAmount: dto.promisedAmount
            ? this.decimal(dto.promisedAmount)
            : null,
          nextFollowup,
          syncId: dto.syncId,
        },
        include: this.callLogInclude(),
      });

      if (dto.taskId) {
        await tx.task.updateMany({
          where: { id: dto.taskId, userId: user.id, deletedAt: null },
          data: { status: TaskStatus.DONE, completedAt: new Date() },
        });
      }

      return { callLog, nextTask };
    });

    return this.toJson(result.callLog, result.nextTask);
  }

  private async createFollowUpTask(
    tx: Prisma.TransactionClient,
    userId: string,
    dto: CreateCallLogDto,
    party: Party | null,
    task: Task | null,
    scheduledAt: Date,
  ) {
    const followUp = dto.followUpTask;
    const syncId = followUp?.syncId ?? randomUUID();
    const existing = await tx.task.findUnique({
      where: { syncId },
      include: this.taskInclude(),
    });

    if (existing) {
      if (existing.userId !== userId) {
        throw new UnauthorizedException("Invalid follow-up sync id");
      }
      if (!existing.deletedAt) {
        return existing;
      }
      return tx.task.update({
        where: { id: existing.id },
        data: {
          ...this.followUpTaskData(userId, dto, party, task, scheduledAt),
          deletedAt: null,
        },
        include: this.taskInclude(),
      });
    }

    return tx.task.create({
      data: {
        id: followUp?.id ?? randomUUID(),
        ...this.followUpTaskData(userId, dto, party, task, scheduledAt),
        syncId,
      },
      include: this.taskInclude(),
    });
  }

  private followUpTaskData(
    userId: string,
    dto: CreateCallLogDto,
    party: Party | null,
    task: Task | null,
    scheduledAt: Date,
  ) {
    const title =
      dto.followUpTask?.title ?? this.followUpTitle(dto, party, task);
    const type =
      dto.outcome === CallOutcome.PAYMENT_PROMISED
        ? TaskType.PAYMENT_COLLECTION
        : TaskType.CALL;

    return {
      userId,
      partyId: party?.id ?? task?.partyId ?? null,
      type,
      title,
      notes: this.cleanNullable(dto.notes),
      scheduledAt,
      priority: dto.outcome === CallOutcome.PAYMENT_PROMISED ? 2 : 1,
      status: TaskStatus.PENDING,
      completedAt: null,
    };
  }

  private followUpTitle(
    dto: CreateCallLogDto,
    party: Party | null,
    task: Task | null,
  ) {
    const name = party?.name;
    if (dto.outcome === CallOutcome.PAYMENT_PROMISED) {
      return name ? `Collect payment from ${name}` : "Collect promised payment";
    }
    if (dto.outcome === CallOutcome.NEW_ORDER) {
      return name
        ? `Follow up on new order from ${name}`
        : "Follow up on new order";
    }
    return task?.title ?? (name ? `Call ${name}` : "Follow up call");
  }

  private nextFollowupAt(dto: CreateCallLogDto, task: Task | null) {
    if (dto.outcome === CallOutcome.PAYMENT_PROMISED) {
      return this.optionalDate(
        dto.followUpTask?.scheduledAt ?? dto.promisedDate,
      );
    }
    if (dto.outcome === CallOutcome.NO_ANSWER) {
      return this.tomorrowAtOriginalTime(dto.followUpTask, task);
    }
    if (dto.outcome === CallOutcome.NEW_ORDER) {
      return this.tomorrowAtTen(dto.followUpTask);
    }
    return null;
  }

  private tomorrowAtOriginalTime(
    followUp: FollowUpTaskDto | undefined,
    task: Task | null,
  ) {
    if (followUp?.scheduledAt) {
      return new Date(followUp.scheduledAt);
    }
    const scheduledAt = task?.scheduledAt
      ? new Date(task.scheduledAt)
      : new Date();
    scheduledAt.setDate(scheduledAt.getDate() + 1);
    if (!task) {
      scheduledAt.setHours(10, 0, 0, 0);
    }
    return scheduledAt;
  }

  private tomorrowAtTen(followUp: FollowUpTaskDto | undefined) {
    if (followUp?.scheduledAt) {
      return new Date(followUp.scheduledAt);
    }
    const scheduledAt = new Date();
    scheduledAt.setDate(scheduledAt.getDate() + 1);
    scheduledAt.setHours(10, 0, 0, 0);
    return scheduledAt;
  }

  private assertOutcome(dto: CreateCallLogDto) {
    if (dto.outcome === CallOutcome.PAYMENT_PROMISED && !dto.promisedDate) {
      throw new BadRequestException("Payment promised requires promised date");
    }
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

  private callLogInclude() {
    return {
      party: { select: this.partySelect() },
      task: {
        select: {
          id: true,
          type: true,
          title: true,
          scheduledAt: true,
          status: true,
        },
      },
    } as const;
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

  private toJson(
    callLog: CallLogWithRelations,
    nextTask?: TaskWithParty | null,
  ) {
    return {
      id: callLog.id,
      userId: callLog.userId,
      taskId: callLog.taskId,
      partyId: callLog.partyId,
      outcome: callLog.outcome,
      notes: callLog.notes,
      promisedDate: callLog.promisedDate?.toISOString() ?? null,
      promisedAmount: callLog.promisedAmount
        ? this.decimalString(callLog.promisedAmount)
        : null,
      nextFollowup: callLog.nextFollowup?.toISOString() ?? null,
      syncId: callLog.syncId,
      createdAt: callLog.createdAt.toISOString(),
      party: callLog.party ? this.partyJson(callLog.party) : null,
      task: callLog.task
        ? {
            id: callLog.task.id,
            type: callLog.task.type,
            title: callLog.task.title,
            scheduledAt: callLog.task.scheduledAt.toISOString(),
            status: callLog.task.status,
          }
        : null,
      nextTask: nextTask ? this.taskJson(nextTask) : null,
    };
  }

  private taskJson(task: TaskWithParty) {
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
      party: task.party ? this.partyJson(task.party) : null,
    };
  }

  private partyJson(
    party: Pick<Party, "id" | "name" | "phone" | "type" | "trustTag">,
  ) {
    return {
      id: party.id,
      name: party.name,
      phone: party.phone,
      type: party.type,
      trustTag: party.trustTag,
    };
  }

  private optionalDate(value?: string | null) {
    return value ? new Date(value) : null;
  }

  private decimal(value: string) {
    return new Prisma.Decimal(value);
  }

  private decimalString(value: Prisma.Decimal | number | string) {
    return new Prisma.Decimal(value).toFixed(2);
  }

  private cleanNullable(value?: string | null) {
    const trimmed = value?.trim();
    return trimmed ? trimmed : null;
  }
}
