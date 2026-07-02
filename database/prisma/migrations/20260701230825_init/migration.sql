-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('ADMIN', 'TEACHER', 'PARENT');

-- CreateEnum
CREATE TYPE "EditorialStatus" AS ENUM ('DRAFT', 'REVIEW', 'PUBLISHED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "Difficulty" AS ENUM ('BEGINNER', 'INTERMEDIATE', 'ADVANCED');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "role" "UserRole" NOT NULL DEFAULT 'PARENT',
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RefreshToken" (
    "id" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "revokedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT NOT NULL,

    CONSTRAINT "RefreshToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ChildProfile" (
    "id" TEXT NOT NULL,
    "nickname" TEXT NOT NULL,
    "age" INTEGER NOT NULL,
    "grade" TEXT,
    "avatar" TEXT NOT NULL DEFAULT 'owl',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "ownerUserId" TEXT NOT NULL,

    CONSTRAINT "ChildProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LearningModule" (
    "id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "color" TEXT NOT NULL,
    "icon" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL,

    CONSTRAINT "LearningModule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Level" (
    "id" TEXT NOT NULL,
    "number" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "difficulty" "Difficulty" NOT NULL DEFAULT 'BEGINNER',
    "status" "EditorialStatus" NOT NULL DEFAULT 'DRAFT',
    "schemaVersion" INTEGER NOT NULL DEFAULT 1,
    "version" INTEGER NOT NULL DEFAULT 1,
    "moduleId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Level_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Activity" (
    "id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "instruction" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "correctAnswer" JSONB NOT NULL,
    "feedback" JSONB NOT NULL,
    "rewardXp" INTEGER NOT NULL DEFAULT 10,
    "rewardStars" INTEGER NOT NULL DEFAULT 10,
    "accessibility" JSONB NOT NULL,
    "sortOrder" INTEGER NOT NULL,
    "levelId" TEXT NOT NULL,

    CONSTRAINT "Activity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ActivityAttempt" (
    "id" TEXT NOT NULL,
    "clientAttemptId" TEXT NOT NULL,
    "answer" JSONB NOT NULL,
    "correct" BOOLEAN NOT NULL,
    "elapsedMs" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "profileId" TEXT NOT NULL,
    "activityId" TEXT NOT NULL,

    CONSTRAINT "ActivityAttempt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProfileActivityCompletion" (
    "id" TEXT NOT NULL,
    "completedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "profileId" TEXT NOT NULL,
    "activityId" TEXT NOT NULL,

    CONSTRAINT "ProfileActivityCompletion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ModuleProgress" (
    "id" TEXT NOT NULL,
    "xp" INTEGER NOT NULL DEFAULT 0,
    "stars" INTEGER NOT NULL DEFAULT 0,
    "correctCount" INTEGER NOT NULL DEFAULT 0,
    "incorrectCount" INTEGER NOT NULL DEFAULT 0,
    "completedActivities" INTEGER NOT NULL DEFAULT 0,
    "currentLevel" INTEGER NOT NULL DEFAULT 1,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "profileId" TEXT NOT NULL,
    "moduleId" TEXT NOT NULL,

    CONSTRAINT "ModuleProgress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Achievement" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "icon" TEXT NOT NULL,

    CONSTRAINT "Achievement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProfileAchievement" (
    "id" TEXT NOT NULL,
    "earnedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "profileId" TEXT NOT NULL,
    "achievementId" TEXT NOT NULL,

    CONSTRAINT "ProfileAchievement_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "RefreshToken_userId_idx" ON "RefreshToken"("userId");

-- CreateIndex
CREATE INDEX "ChildProfile_ownerUserId_idx" ON "ChildProfile"("ownerUserId");

-- CreateIndex
CREATE UNIQUE INDEX "LearningModule_slug_key" ON "LearningModule"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "LearningModule_sortOrder_key" ON "LearningModule"("sortOrder");

-- CreateIndex
CREATE INDEX "Level_moduleId_status_idx" ON "Level"("moduleId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Level_moduleId_number_key" ON "Level"("moduleId", "number");

-- CreateIndex
CREATE INDEX "Activity_levelId_idx" ON "Activity"("levelId");

-- CreateIndex
CREATE UNIQUE INDEX "Activity_levelId_sortOrder_key" ON "Activity"("levelId", "sortOrder");

-- CreateIndex
CREATE UNIQUE INDEX "ActivityAttempt_clientAttemptId_key" ON "ActivityAttempt"("clientAttemptId");

-- CreateIndex
CREATE INDEX "ActivityAttempt_profileId_activityId_idx" ON "ActivityAttempt"("profileId", "activityId");

-- CreateIndex
CREATE UNIQUE INDEX "ProfileActivityCompletion_profileId_activityId_key" ON "ProfileActivityCompletion"("profileId", "activityId");

-- CreateIndex
CREATE UNIQUE INDEX "ModuleProgress_profileId_moduleId_key" ON "ModuleProgress"("profileId", "moduleId");

-- CreateIndex
CREATE UNIQUE INDEX "ProfileAchievement_profileId_achievementId_key" ON "ProfileAchievement"("profileId", "achievementId");

-- AddForeignKey
ALTER TABLE "RefreshToken" ADD CONSTRAINT "RefreshToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChildProfile" ADD CONSTRAINT "ChildProfile_ownerUserId_fkey" FOREIGN KEY ("ownerUserId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Level" ADD CONSTRAINT "Level_moduleId_fkey" FOREIGN KEY ("moduleId") REFERENCES "LearningModule"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Activity" ADD CONSTRAINT "Activity_levelId_fkey" FOREIGN KEY ("levelId") REFERENCES "Level"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ActivityAttempt" ADD CONSTRAINT "ActivityAttempt_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "ChildProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ActivityAttempt" ADD CONSTRAINT "ActivityAttempt_activityId_fkey" FOREIGN KEY ("activityId") REFERENCES "Activity"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileActivityCompletion" ADD CONSTRAINT "ProfileActivityCompletion_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "ChildProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileActivityCompletion" ADD CONSTRAINT "ProfileActivityCompletion_activityId_fkey" FOREIGN KEY ("activityId") REFERENCES "Activity"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ModuleProgress" ADD CONSTRAINT "ModuleProgress_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "ChildProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ModuleProgress" ADD CONSTRAINT "ModuleProgress_moduleId_fkey" FOREIGN KEY ("moduleId") REFERENCES "LearningModule"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileAchievement" ADD CONSTRAINT "ProfileAchievement_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "ChildProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileAchievement" ADD CONSTRAINT "ProfileAchievement_achievementId_fkey" FOREIGN KEY ("achievementId") REFERENCES "Achievement"("id") ON DELETE CASCADE ON UPDATE CASCADE;
