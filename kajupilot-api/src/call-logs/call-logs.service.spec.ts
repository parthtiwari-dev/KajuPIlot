import { BadRequestException } from "@nestjs/common";
import { CallOutcome, Role, TaskStatus, TaskType } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { CallLogsService } from "./call-logs.service";

describe("CallLogsService", () => {
  let service: CallLogsService;
  let prisma: any;
  let tx: any;

  const user = {
    id: "user-1",
    role: Role.OWNER,
    name: "Owner",
    businessName: null,
  };

  beforeEach(() => {
    tx = {
      task: {
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        updateMany: jest.fn(),
      },
      callLog: { create: jest.fn() },
    };
    prisma = {
      callLog: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
      },
      task: { findFirst: jest.fn() },
      party: { findFirst: jest.fn() },
      $transaction: jest.fn((callback) => callback(tx)),
    };
    service = new CallLogsService(prisma as PrismaService);
  });

  it("creates payment promised call log with one follow-up task", async () => {
    prisma.callLog.findUnique.mockResolvedValueOnce(null);
    prisma.task.findFirst.mockResolvedValueOnce(task());
    prisma.party.findFirst.mockResolvedValueOnce(party());
    tx.task.findUnique.mockResolvedValueOnce(null);
    tx.task.create.mockResolvedValueOnce(task({ id: "next-task" }));
    tx.callLog.create.mockResolvedValueOnce(callLog());

    const result = await service.create(user, {
      id: "call-1",
      taskId: "task-1",
      partyId: "party-1",
      outcome: CallOutcome.PAYMENT_PROMISED,
      promisedDate: "2026-06-08T10:00:00.000Z",
      followUpTask: {
        id: "next-task",
        syncId: "next-sync",
        scheduledAt: "2026-06-08T10:00:00.000Z",
      },
      syncId: "call-sync",
    });

    expect(tx.task.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        id: "next-task",
        type: TaskType.PAYMENT_COLLECTION,
        syncId: "next-sync",
      }),
      include: expect.any(Object),
    });
    expect(tx.task.updateMany).toHaveBeenCalledWith({
      where: { id: "task-1", userId: "user-1", deletedAt: null },
      data: expect.objectContaining({ status: TaskStatus.DONE }),
    });
    expect(result.outcome).toBe(CallOutcome.PAYMENT_PROMISED);
  });

  it("does not repeat side effects for duplicate call log syncId", async () => {
    prisma.callLog.findUnique.mockResolvedValueOnce(callLog());

    const result = await service.create(user, {
      outcome: CallOutcome.NO_ANSWER,
      syncId: "call-sync",
    });

    expect(prisma.$transaction).not.toHaveBeenCalled();
    expect(result.syncId).toBe("call-sync");
  });

  it("requires promised date for payment promised outcome", async () => {
    prisma.callLog.findUnique.mockResolvedValueOnce(null);

    await expect(
      service.create(user, {
        outcome: CallOutcome.PAYMENT_PROMISED,
        syncId: "call-sync",
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});

function party() {
  return {
    id: "party-1",
    name: "Amit Verma",
    phone: "98765",
    type: "CUSTOMER",
    trustTag: "NEW",
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
    syncId: "task-sync",
    createdAt: new Date("2026-06-07T08:00:00.000Z"),
    updatedAt: new Date("2026-06-07T08:00:00.000Z"),
    deletedAt: null,
    party: party(),
    ...overrides,
  };
}

function callLog(overrides: Record<string, unknown> = {}) {
  return {
    id: "call-1",
    userId: "user-1",
    taskId: "task-1",
    partyId: "party-1",
    outcome: CallOutcome.PAYMENT_PROMISED,
    notes: null,
    promisedDate: new Date("2026-06-08T10:00:00.000Z"),
    promisedAmount: null,
    nextFollowup: new Date("2026-06-08T10:00:00.000Z"),
    syncId: "call-sync",
    createdAt: new Date("2026-06-07T11:00:00.000Z"),
    party: party(),
    task: {
      id: "task-1",
      type: TaskType.CALL,
      title: "Call Amit",
      scheduledAt: new Date("2026-06-07T10:00:00.000Z"),
      status: TaskStatus.DONE,
    },
    ...overrides,
  };
}
