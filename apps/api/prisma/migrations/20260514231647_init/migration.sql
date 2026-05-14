-- CreateEnum
CREATE TYPE "ActionCategory" AS ENUM ('STABILIZE', 'BUILD', 'RESTORE');

-- CreateEnum
CREATE TYPE "ActionStatus" AS ENUM ('INBOX', 'ACTIVE', 'PAUSED', 'DONE', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "EffortLevel" AS ENUM ('LOW', 'MEDIUM', 'HIGH');

-- CreateEnum
CREATE TYPE "ImpactLevel" AS ENUM ('LOW', 'MEDIUM', 'HIGH');

-- CreateEnum
CREATE TYPE "UrgencyLevel" AS ENUM ('LOW', 'MEDIUM', 'HIGH');

-- CreateEnum
CREATE TYPE "CapacityLevel" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'RECOVERY');

-- CreateEnum
CREATE TYPE "DayMode" AS ENUM ('STABILIZE', 'BUILD', 'RESTORE', 'MIXED');

-- CreateTable
CREATE TABLE "ActionItem" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "category" "ActionCategory" NOT NULL DEFAULT 'STABILIZE',
    "supportsStability" BOOLEAN NOT NULL DEFAULT false,
    "effort" "EffortLevel" NOT NULL DEFAULT 'MEDIUM',
    "impact" "ImpactLevel" NOT NULL DEFAULT 'MEDIUM',
    "urgency" "UrgencyLevel" NOT NULL DEFAULT 'MEDIUM',
    "status" "ActionStatus" NOT NULL DEFAULT 'INBOX',
    "dueDate" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "ActionItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CapacityCheckIn" (
    "id" TEXT NOT NULL,
    "energy" "CapacityLevel" NOT NULL,
    "stress" "CapacityLevel" NOT NULL,
    "availableTime" INTEGER,
    "mode" "DayMode" NOT NULL DEFAULT 'MIXED',
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CapacityCheckIn_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Reflection" (
    "id" TEXT NOT NULL,
    "actionItemId" TEXT,
    "stressReduced" BOOLEAN,
    "momentumCreated" BOOLEAN,
    "actualEffort" "EffortLevel",
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Reflection_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Reflection" ADD CONSTRAINT "Reflection_actionItemId_fkey" FOREIGN KEY ("actionItemId") REFERENCES "ActionItem"("id") ON DELETE SET NULL ON UPDATE CASCADE;
