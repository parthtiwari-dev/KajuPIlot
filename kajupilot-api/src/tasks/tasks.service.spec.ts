import { UnauthorizedException } from "@nestjs/common";
import { Role, TaskStatus, TaskType } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { TasksService } from "./tasks.service";

describe("TasksService", () => {
  let service: TasksService;
  let prisma: {
    task: {
      findMany: jest.Mock;
      findUnique: jest.Mock;
      findFirst: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
    };
    party: { findFirst: jest.Mock };
  };

  const user = {
    id: "user-1",
    role: Role.OWNER,
    name: "Owner",
    businessName: null,
  };

  beforeEach(() => {
    prisma = {
      task: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      party: { findFirst: jest.fn() },
    };
    service = new TasksService(prisma as unknown as PrismaService);
  });

  it("creates a task scoped to the current user", async () => {
    prisma.task.findUnique.mockResolvedValueOnce(null);
    prisma.party.findFirst.mockResolvedValueOnce({ id: "party-1" });
    prisma.task.create.mockImplementation(async ({ data }) => task(data));

    const result = await service.create(user, createDto());

    expect(prisma.task.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        id: "task-1",
        userId: "user-1",
        partyId: "party-1",
        type: TaskType.CALL,
        syncId: "sync-1",
      }),
      include: expect.any(Object),
    });
    expect(result).toMatchObject({
      id: "task-1",
      userId: "user-1",
      partyId: "party-1",
      type: TaskType.CALL,
    });
  });

  it("returns existing same-user task when syncId is duplicated", async () => {
    prisma.task.findUnique.mockResolvedValueOnce(task());

    const result = await service.create(user, createDto());

    expect(prisma.task.create).not.toHaveBeenCalled();
    expect(result.syncId).toBe("sync-1");
  });

  it("rejects duplicate syncId owned by another user", async () => {
    prisma.task.findUnique.mockResolvedValueOnce(task({ userId: "user-2" }));

    await expect(service.create(user, createDto())).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });

  it("sorts today tasks overdue first, then priority, then time", async () => {
    prisma.task.findMany.mockResolvedValueOnce([
      task({
        id: "later",
        scheduledAt: new Date("2026-06-07T16:00:00.000Z"),
        priority: 5,
      }),
      task({
        id: "overdue",
        scheduledAt: new Date("2020-06-07T09:00:00.000Z"),
        priority: 0,
      }),
      task({
        id: "priority",
        scheduledAt: new Date("2026-06-07T15:00:00.000Z"),
        priority: 4,
      }),
    ]);

    const result = await service.today(user, "2026-06-07");

    expect(result.map((item) => item.id)).toEqual([
      "overdue",
      "later",
      "priority",
    ]);
  });

  it("completes, postpones, and soft deletes tasks", async () => {
    prisma.task.findFirst.mockResolvedValue(task());
    prisma.task.update.mockImplementation(async ({ data }) => task(data));

    const done = await service.complete(user, "task-1");
    const postponed = await service.postpone(
      user,
      "task-1",
      "2026-06-08T10:00:00.000Z",
    );
    const deleted = await service.remove(user, "task-1");

    expect(done.status).toBe(TaskStatus.DONE);
    expect(postponed.status).toBe(TaskStatus.POSTPONED);
    expect(deleted.deletedAt).toEqual(expect.any(String));
  });
});

function createDto(overrides = {}) {
  return {
    id: "task-1",
    partyId: "party-1",
    type: TaskType.CALL,
    title: "Call Amit",
    scheduledAt: "2026-06-07T10:00:00.000Z",
    priority: 1,
    syncId: "sync-1",
    ...overrides,
  };
}

function task(overrides: Record<string, unknown> = {}) {
  return {
    id: "task-1",
    userId: "user-1",
    partyId: "party-1",
    type: TaskType.CALL,
    title: "Call Amit",
    notes: null,
    scheduledAt: new Date("2026-06-07T10:00:00.000Z"),
    completedAt: null,
    status: TaskStatus.PENDING,
    priority: 1,
    syncId: "sync-1",
    createdAt: new Date("2026-06-07T08:00:00.000Z"),
    updatedAt: new Date("2026-06-07T08:00:00.000Z"),
    deletedAt: null,
    party: {
      id: "party-1",
      name: "Amit Verma",
      phone: "98765",
      type: "CUSTOMER",
      trustTag: "NEW",
    },
    ...overrides,
  };
}
