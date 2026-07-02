import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import type { User } from '@prisma/client';
import * as argon2 from 'argon2';
import { randomUUID } from 'node:crypto';
import { PrismaService } from '../../prisma/prisma.service';
import type { LoginDto } from './dto/login.dto';
import type { RefreshDto } from './dto/refresh.dto';
import type { RegisterDto } from './dto/register.dto';

interface RefreshPayload { sub: string; tokenId: string; type: 'refresh' }

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    const email = dto.email.trim().toLowerCase();
    if (await this.prisma.user.findUnique({ where: { email } })) throw new ConflictException('El correo ya está registrado');
    const user = await this.prisma.user.create({ data: { email, passwordHash: await argon2.hash(dto.password) } });
    return this.issueSession(user);
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email.trim().toLowerCase() } });
    if (!user || !user.active || !(await argon2.verify(user.passwordHash, dto.password))) {
      throw new UnauthorizedException('Correo o contraseña incorrectos');
    }
    return this.issueSession(user);
  }

  async refresh(dto: RefreshDto) {
    let payload: RefreshPayload;
    try {
      payload = await this.jwt.verifyAsync<RefreshPayload>(dto.refreshToken, { secret: this.config.getOrThrow('JWT_REFRESH_SECRET') });
    } catch { throw new UnauthorizedException('Sesión inválida o vencida'); }
    if (payload.type !== 'refresh') throw new UnauthorizedException('Token inválido');
    const stored = await this.prisma.refreshToken.findUnique({ where: { id: payload.tokenId }, include: { user: true } });
    if (!stored || stored.revokedAt || stored.expiresAt <= new Date() || !(await argon2.verify(stored.tokenHash, dto.refreshToken))) {
      throw new UnauthorizedException('La sesión fue revocada');
    }
    await this.prisma.refreshToken.update({ where: { id: stored.id }, data: { revokedAt: new Date() } });
    return this.issueSession(stored.user);
  }

  async logout(dto: RefreshDto) {
    try {
      const payload = await this.jwt.verifyAsync<RefreshPayload>(dto.refreshToken, { secret: this.config.getOrThrow('JWT_REFRESH_SECRET'), ignoreExpiration: true });
      await this.prisma.refreshToken.updateMany({ where: { id: payload.tokenId, userId: payload.sub }, data: { revokedAt: new Date() } });
    } catch { /* logout remains idempotent */ }
    return { success: true };
  }

  async me(userId: string) {
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
    return this.publicUser(user);
  }

  private async issueSession(user: User) {
    const tokenId = randomUUID();
    const accessToken = await this.jwt.signAsync(
      { sub: user.id, email: user.email, role: user.role },
      { secret: this.config.getOrThrow('JWT_ACCESS_SECRET'), expiresIn: this.config.get('ACCESS_TOKEN_TTL') ?? '15m' },
    );
    const refreshToken = await this.jwt.signAsync(
      { sub: user.id, tokenId, type: 'refresh' satisfies RefreshPayload['type'] },
      { secret: this.config.getOrThrow('JWT_REFRESH_SECRET'), expiresIn: this.config.get('REFRESH_TOKEN_TTL') ?? '7d' },
    );
    const decoded = this.jwt.decode(refreshToken) as { exp: number };
    await this.prisma.refreshToken.create({
      data: { id: tokenId, userId: user.id, tokenHash: await argon2.hash(refreshToken), expiresAt: new Date(decoded.exp * 1000) },
    });
    return { user: this.publicUser(user), accessToken, refreshToken };
  }

  private publicUser(user: User) { return { id: user.id, email: user.email, role: user.role }; }
}
