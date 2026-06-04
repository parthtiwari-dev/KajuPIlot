-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "Role" AS ENUM ('OWNER', 'ADMIN');

-- CreateEnum
CREATE TYPE "PartyType" AS ENUM ('CUSTOMER', 'SUPPLIER', 'BOTH');

-- CreateEnum
CREATE TYPE "TrustTag" AS ENUM ('RELIABLE', 'SLOW_PAYER', 'RISKY', 'NEW');

-- CreateEnum
CREATE TYPE "DealType" AS ENUM ('SALE', 'PURCHASE');

-- CreateEnum
CREATE TYPE "DealStatus" AS ENUM ('QUOTED', 'CONFIRMED', 'DELIVERED', 'PAID');

-- CreateEnum
CREATE TYPE "PaymentType" AS ENUM ('RECEIVED', 'PAID');

-- CreateEnum
CREATE TYPE "ExpenseCategory" AS ENUM ('TRANSPORT', 'LABOUR', 'PACKAGING', 'BROKER_COMMISSION', 'STOCK_PURCHASE', 'OTHER');

-- CreateEnum
CREATE TYPE "TaskType" AS ENUM ('CALL', 'DELIVERY', 'PAYMENT_COLLECTION', 'REMINDER', 'OTHER');

-- CreateEnum
CREATE TYPE "TaskStatus" AS ENUM ('PENDING', 'DONE', 'POSTPONED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "CallOutcome" AS ENUM ('PAYMENT_PROMISED', 'NEW_ORDER', 'NO_ANSWER', 'NOT_INTERESTED', 'DELIVERY_UPDATE', 'OTHER');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "businessName" TEXT,
    "deviceToken" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'OWNER',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Party" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT,
    "type" "PartyType" NOT NULL DEFAULT 'CUSTOMER',
    "trustTag" "TrustTag" NOT NULL DEFAULT 'NEW',
    "notes" TEXT,
    "syncId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "Party_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Deal" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "partyId" TEXT NOT NULL,
    "type" "DealType" NOT NULL DEFAULT 'SALE',
    "cashewGrade" TEXT NOT NULL,
    "quantityKg" DECIMAL(10,2) NOT NULL,
    "ratePerKg" DECIMAL(10,2) NOT NULL,
    "totalAmount" DECIMAL(14,2) NOT NULL,
    "paidAmount" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "status" "DealStatus" NOT NULL DEFAULT 'CONFIRMED',
    "deliveryDate" TIMESTAMP(3),
    "paymentDue" TIMESTAMP(3),
    "notes" TEXT,
    "syncId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "Deal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Payment" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "partyId" TEXT NOT NULL,
    "dealId" TEXT,
    "type" "PaymentType" NOT NULL,
    "amount" DECIMAL(14,2) NOT NULL,
    "method" TEXT,
    "notes" TEXT,
    "paymentDate" TIMESTAMP(3) NOT NULL,
    "syncId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Expense" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "category" "ExpenseCategory" NOT NULL,
    "amount" DECIMAL(14,2) NOT NULL,
    "notes" TEXT,
    "expenseDate" TIMESTAMP(3) NOT NULL,
    "syncId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "Expense_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Task" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "partyId" TEXT,
    "type" "TaskType" NOT NULL,
    "title" TEXT NOT NULL,
    "notes" TEXT,
    "scheduledAt" TIMESTAMP(3) NOT NULL,
    "completedAt" TIMESTAMP(3),
    "status" "TaskStatus" NOT NULL DEFAULT 'PENDING',
    "priority" INTEGER NOT NULL DEFAULT 0,
    "syncId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "Task_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CallLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "taskId" TEXT,
    "partyId" TEXT,
    "outcome" "CallOutcome" NOT NULL,
    "notes" TEXT,
    "promisedDate" TIMESTAMP(3),
    "promisedAmount" DECIMAL(14,2),
    "nextFollowup" TIMESTAMP(3),
    "syncId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CallLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiParseLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "rawInput" TEXT NOT NULL,
    "parsedJson" JSONB NOT NULL,
    "confirmed" BOOLEAN NOT NULL DEFAULT false,
    "confirmedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AiParseLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_deviceToken_key" ON "User"("deviceToken");

-- CreateIndex
CREATE UNIQUE INDEX "Party_syncId_key" ON "Party"("syncId");

-- CreateIndex
CREATE INDEX "Party_userId_deletedAt_idx" ON "Party"("userId", "deletedAt");

-- CreateIndex
CREATE UNIQUE INDEX "Deal_syncId_key" ON "Deal"("syncId");

-- CreateIndex
CREATE INDEX "Deal_userId_status_deletedAt_idx" ON "Deal"("userId", "status", "deletedAt");

-- CreateIndex
CREATE INDEX "Deal_partyId_deletedAt_idx" ON "Deal"("partyId", "deletedAt");

-- CreateIndex
CREATE INDEX "Deal_paymentDue_idx" ON "Deal"("paymentDue");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_syncId_key" ON "Payment"("syncId");

-- CreateIndex
CREATE INDEX "Payment_userId_paymentDate_deletedAt_idx" ON "Payment"("userId", "paymentDate", "deletedAt");

-- CreateIndex
CREATE INDEX "Payment_partyId_deletedAt_idx" ON "Payment"("partyId", "deletedAt");

-- CreateIndex
CREATE UNIQUE INDEX "Expense_syncId_key" ON "Expense"("syncId");

-- CreateIndex
CREATE INDEX "Expense_userId_expenseDate_deletedAt_idx" ON "Expense"("userId", "expenseDate", "deletedAt");

-- CreateIndex
CREATE UNIQUE INDEX "Task_syncId_key" ON "Task"("syncId");

-- CreateIndex
CREATE INDEX "Task_userId_scheduledAt_deletedAt_idx" ON "Task"("userId", "scheduledAt", "deletedAt");

-- CreateIndex
CREATE INDEX "Task_userId_status_deletedAt_idx" ON "Task"("userId", "status", "deletedAt");

-- CreateIndex
CREATE UNIQUE INDEX "CallLog_syncId_key" ON "CallLog"("syncId");

-- CreateIndex
CREATE INDEX "AiParseLog_userId_createdAt_idx" ON "AiParseLog"("userId", "createdAt");

-- AddForeignKey
ALTER TABLE "Party" ADD CONSTRAINT "Party_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Deal" ADD CONSTRAINT "Deal_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Deal" ADD CONSTRAINT "Deal_partyId_fkey" FOREIGN KEY ("partyId") REFERENCES "Party"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_partyId_fkey" FOREIGN KEY ("partyId") REFERENCES "Party"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Task" ADD CONSTRAINT "Task_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Task" ADD CONSTRAINT "Task_partyId_fkey" FOREIGN KEY ("partyId") REFERENCES "Party"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CallLog" ADD CONSTRAINT "CallLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CallLog" ADD CONSTRAINT "CallLog_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "Task"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CallLog" ADD CONSTRAINT "CallLog_partyId_fkey" FOREIGN KEY ("partyId") REFERENCES "Party"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiParseLog" ADD CONSTRAINT "AiParseLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
