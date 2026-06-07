ALTER TABLE "Party" ADD COLUMN "trustTagManualOverride" BOOLEAN NOT NULL DEFAULT false;

UPDATE "Party"
SET "trustTagManualOverride" = true
WHERE "trustTag" <> 'NEW';
