import { Controller, Get } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { PrismaService } from '../../prisma/prisma.service';

@ApiTags('health')
@Controller({ path: 'health', version: '1' })
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  async check() {
    await this.prisma.$queryRaw`SELECT 1`;
    return { status: 'ok', database: 'connected', timestamp: new Date().toISOString() };
  }
}
