import { Prisma, PrismaClient, UserRole } from "@prisma/client";
import * as argon2 from "argon2";
import { readFileSync, readdirSync } from "node:fs";
import { join, resolve } from "node:path";

const prisma = new PrismaClient();
const root = resolve(__dirname, "../..");
const moduleDefinitions = [
  {
    id: "mathematics",
    slug: "mathematics",
    name: "Matemáticas",
    description: "Números y formas",
    color: "#2878E8",
    icon: "calculate",
    sortOrder: 1,
    folder: "mathematics",
  },
  {
    id: "letters",
    slug: "letters",
    name: "Letras",
    description: "Palabras e historias",
    color: "#2E9F69",
    icon: "menu_book",
    sortOrder: 2,
    folder: "letters",
  },
  {
    id: "logic",
    slug: "logic",
    name: "Lógica",
    description: "Patrones y memoria",
    color: "#F06C27",
    icon: "extension",
    sortOrder: 3,
    folder: "logic",
  },
  {
    id: "art",
    slug: "art",
    name: "Arte",
    description: "Colores y creatividad",
    color: "#D9478D",
    icon: "palette",
    sortOrder: 4,
    folder: "art",
  },
];

type ContentLevel = {
  schemaVersion: number;
  id: string;
  module: string;
  levelNumber: number;
  title: string;
  status: "DRAFT" | "REVIEW" | "PUBLISHED" | "ARCHIVED";
  activities: Array<{
    id: string;
    type: string;
    instruction: string;
    payload: unknown;
    answer: unknown;
    feedback: unknown;
    reward: { xp: number; stars: number };
    accessibility: unknown;
  }>;
};

async function main() {
  for (const definition of moduleDefinitions) {
    const { folder, ...moduleData } = definition;
    await prisma.learningModule.upsert({
      where: { id: definition.id },
      update: moduleData,
      create: moduleData,
    });
    const folderPath = join(root, "content", folder);
    for (const file of readdirSync(folderPath)
      .filter((name) => name.endsWith(".json"))
      .sort()) {
      const content = JSON.parse(
        readFileSync(join(folderPath, file), "utf8"),
      ) as ContentLevel;
      await prisma.level.upsert({
        where: { id: content.id },
        update: {
          title: content.title,
          number: content.levelNumber,
          status: content.status,
          schemaVersion: content.schemaVersion,
          moduleId: definition.id,
        },
        create: {
          id: content.id,
          title: content.title,
          number: content.levelNumber,
          status: content.status,
          schemaVersion: content.schemaVersion,
          moduleId: definition.id,
        },
      });
      for (const [index, activity] of content.activities.entries()) {
        await prisma.activity.upsert({
          where: { id: activity.id },
          update: {
            type: activity.type,
            instruction: activity.instruction,
            payload: activity.payload as Prisma.InputJsonValue,
            correctAnswer: activity.answer as Prisma.InputJsonValue,
            feedback: activity.feedback as Prisma.InputJsonValue,
            rewardXp: activity.reward.xp,
            rewardStars: activity.reward.stars,
            accessibility: activity.accessibility as Prisma.InputJsonValue,
            sortOrder: index + 1,
            levelId: content.id,
          },
          create: {
            id: activity.id,
            type: activity.type,
            instruction: activity.instruction,
            payload: activity.payload as Prisma.InputJsonValue,
            correctAnswer: activity.answer as Prisma.InputJsonValue,
            feedback: activity.feedback as Prisma.InputJsonValue,
            rewardXp: activity.reward.xp,
            rewardStars: activity.reward.stars,
            accessibility: activity.accessibility as Prisma.InputJsonValue,
            sortOrder: index + 1,
            levelId: content.id,
          },
        });
      }
    }
  }

  await prisma.achievement.upsert({
    where: { id: "first-adventure" },
    update: {},
    create: {
      id: "first-adventure",
      name: "Primera aventura",
      description: "Completa tu primera actividad",
      icon: "emoji_events",
    },
  });

  if (process.env.SEED_DEMO_ACCOUNT === "true") {
    const email = "familia@demo.local";
    const user = await prisma.user.upsert({
      where: { email },
      update: {},
      create: {
        email,
        passwordHash: await argon2.hash("DemoAprende123!"),
        role: UserRole.PARENT,
      },
    });
    for (const child of [
      { nickname: "Valentina", age: 6, avatar: "fox" },
      { nickname: "Mateo", age: 5, avatar: "panda" },
    ]) {
      const exists = await prisma.childProfile.findFirst({
        where: { ownerUserId: user.id, nickname: child.nickname },
      });
      if (!exists)
        await prisma.childProfile.create({
          data: { ...child, ownerUserId: user.id },
        });
    }
  }
  console.log("Seed completado: 4 modulos, contenido v1 y demo opcional.");
}

main().finally(() => prisma.$disconnect());
