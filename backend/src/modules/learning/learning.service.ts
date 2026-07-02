import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { ProfilesService } from '../profiles/profiles.service';
import type { SubmitAttemptDto } from './dto/submit-attempt.dto';

@Injectable()
export class LearningService {
  constructor(private readonly prisma: PrismaService, private readonly profiles: ProfilesService) {}

  async modules(ownerUserId: string, profileId: string) {
    await this.profiles.requireOwned(ownerUserId, profileId);
    const modules = await this.prisma.learningModule.findMany({
      orderBy: { sortOrder: 'asc' },
      include: { progress: { where: { profileId } }, _count: { select: { levels: { where: { status: 'PUBLISHED' } } } } },
    });
    return modules.map(({ progress, _count, ...module }) => ({ ...module, publishedLevels: _count.levels, progress: progress[0] ?? null }));
  }

  async levels(ownerUserId: string, moduleId: string, profileId: string) {
    await this.profiles.requireOwned(ownerUserId, profileId);
    const module = await this.prisma.learningModule.findUnique({ where: { id: moduleId } });
    if (!module) throw new NotFoundException('Módulo no encontrado');
    const levels = await this.prisma.level.findMany({
      where: { moduleId, status: 'PUBLISHED' }, orderBy: { number: 'asc' },
      select: {
        id: true, number: true, title: true, difficulty: true, version: true,
        activities: { orderBy: { sortOrder: 'asc' }, select: { id: true, type: true, instruction: true, sortOrder: true } },
        _count: { select: { activities: true } },
      },
    });
    const progress = await this.prisma.moduleProgress.findUnique({ where: { profileId_moduleId: { profileId, moduleId } } });
    return { module, progress, levels: levels.map(level => ({ ...level, unlocked: level.number <= (progress?.currentLevel ?? 1) })) };
  }

  async activity(ownerUserId: string, id: string, profileId: string) {
    await this.profiles.requireOwned(ownerUserId, profileId);
    const activity = await this.prisma.activity.findFirst({
      where: { id, level: { status: 'PUBLISHED' } },
      select: { id: true, type: true, instruction: true, payload: true, feedback: true, rewardXp: true, rewardStars: true, accessibility: true, sortOrder: true, level: { select: { id: true, number: true, moduleId: true, version: true } } },
    });
    if (!activity) throw new NotFoundException('Actividad no encontrada');
    return activity;
  }

  async submitAttempt(ownerUserId: string, activityId: string, dto: SubmitAttemptDto) {
    await this.profiles.requireOwned(ownerUserId, dto.profileId);
    const existing = await this.prisma.activityAttempt.findUnique({ where: { clientAttemptId: dto.clientAttemptId } });
    if (existing) {
      if (existing.profileId !== dto.profileId || existing.activityId !== activityId) throw new NotFoundException('Intento no encontrado');
      const source = await this.prisma.activity.findUniqueOrThrow({ where: { id: activityId } });
      return this.attemptResponse(existing, {
        earned: { xp: 0, stars: 0 },
        feedback: (source.feedback as { correct: string; incorrect: string })[existing.correct ? 'correct' : 'incorrect'],
      }, true);
    }
    const activity = await this.prisma.activity.findFirst({ where: { id: activityId, level: { status: 'PUBLISHED' } }, include: { level: true } });
    if (!activity) throw new NotFoundException('Actividad no encontrada');
    const correct = stableJson(activity.correctAnswer) === stableJson(dto.answer);

    const result = await this.prisma.$transaction(async (tx) => {
      const attempt = await tx.activityAttempt.create({
        data: { clientAttemptId: dto.clientAttemptId, profileId: dto.profileId, activityId, answer: dto.answer as Prisma.InputJsonValue, correct, elapsedMs: dto.elapsedMs },
      });
      const completion = correct
        ? await tx.profileActivityCompletion.createMany({ data: [{ profileId: dto.profileId, activityId }], skipDuplicates: true })
        : { count: 0 };
      const firstCompletion = completion.count === 1;
      const progress = await tx.moduleProgress.upsert({
        where: { profileId_moduleId: { profileId: dto.profileId, moduleId: activity.level.moduleId } },
        create: {
          profileId: dto.profileId, moduleId: activity.level.moduleId,
          xp: firstCompletion ? activity.rewardXp : 0, stars: firstCompletion ? activity.rewardStars : 0,
          correctCount: correct ? 1 : 0, incorrectCount: correct ? 0 : 1,
          completedActivities: firstCompletion ? 1 : 0,
        },
        update: {
          xp: { increment: firstCompletion ? activity.rewardXp : 0 }, stars: { increment: firstCompletion ? activity.rewardStars : 0 },
          correctCount: { increment: correct ? 1 : 0 }, incorrectCount: { increment: correct ? 0 : 1 },
          completedActivities: { increment: firstCompletion ? 1 : 0 },
        },
      });
      return { attempt, progress, firstCompletion };
    });
    return this.attemptResponse(result.attempt, {
      progress: result.progress,
      earned: { xp: result.firstCompletion ? activity.rewardXp : 0, stars: result.firstCompletion ? activity.rewardStars : 0 },
      feedback: (activity.feedback as { correct: string; incorrect: string })[correct ? 'correct' : 'incorrect'],
    }, false);
  }

  private attemptResponse(attempt: { id: string; clientAttemptId: string; correct: boolean; createdAt: Date }, extra: object | null, idempotent: boolean) {
    return { attemptId: attempt.id, clientAttemptId: attempt.clientAttemptId, correct: attempt.correct, createdAt: attempt.createdAt, idempotent, ...extra };
  }
}

function stableJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(',')}]`;
  if (value && typeof value === 'object') return `{${Object.entries(value as Record<string, unknown>).sort(([a], [b]) => a.localeCompare(b)).map(([key, val]) => `${JSON.stringify(key)}:${stableJson(val)}`).join(',')}}`;
  return JSON.stringify(value);
}

export { stableJson };
