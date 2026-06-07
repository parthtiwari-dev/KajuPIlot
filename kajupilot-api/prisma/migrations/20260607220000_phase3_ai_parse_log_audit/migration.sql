ALTER TABLE "AiParseLog"
ADD COLUMN "provider" TEXT,
ADD COLUMN "model" TEXT,
ADD COLUMN "usageJson" JSONB,
ADD COLUMN "error" TEXT,
ADD COLUMN "confirmedJson" JSONB;
