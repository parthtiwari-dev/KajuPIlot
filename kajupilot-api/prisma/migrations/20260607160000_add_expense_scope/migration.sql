CREATE TYPE "ExpenseScope" AS ENUM ('BUSINESS', 'PERSONAL');

ALTER TABLE "Expense"
ADD COLUMN "scope" "ExpenseScope" NOT NULL DEFAULT 'BUSINESS';

CREATE INDEX "Expense_userId_scope_expenseDate_deletedAt_idx"
ON "Expense"("userId", "scope", "expenseDate", "deletedAt");
