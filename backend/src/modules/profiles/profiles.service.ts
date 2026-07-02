import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import type { CreateProfileDto } from './dto/create-profile.dto';
import type { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class ProfilesService {
  constructor(private readonly prisma: PrismaService) {}

  list(ownerUserId: string) {
    return this.prisma.childProfile.findMany({ where: { ownerUserId }, orderBy: { createdAt: 'asc' } });
  }

  create(ownerUserId: string, dto: CreateProfileDto) {
    return this.prisma.childProfile.create({ data: { ...dto, nickname: dto.nickname.trim(), ownerUserId } });
  }

  async update(ownerUserId: string, id: string, dto: UpdateProfileDto) {
    await this.requireOwned(ownerUserId, id);
    return this.prisma.childProfile.update({ where: { id }, data: { ...dto, nickname: dto.nickname?.trim() } });
  }

  async progress(ownerUserId: string, id: string) {
    await this.requireOwned(ownerUserId, id);
    return this.prisma.childProfile.findUniqueOrThrow({
      where: { id },
      select: {
        id: true, nickname: true,
        progress: { include: { module: true }, orderBy: { module: { sortOrder: 'asc' } } },
        achievements: { include: { achievement: true }, orderBy: { earnedAt: 'desc' } },
      },
    });
  }

  async requireOwned(ownerUserId: string, id: string) {
    const profile = await this.prisma.childProfile.findFirst({ where: { id, ownerUserId } });
    if (!profile) throw new NotFoundException('Perfil no encontrado');
    return profile;
  }
}
