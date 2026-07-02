import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { AuthUser } from '../../common/auth/auth-user';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { CreateProfileDto } from './dto/create-profile.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ProfilesService } from './profiles.service';

@ApiTags('profiles')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: 'profiles', version: '1' })
export class ProfilesController {
  constructor(private readonly profiles: ProfilesService) {}

  @Get() list(@CurrentUser() user: AuthUser) { return this.profiles.list(user.sub); }
  @Post() create(@CurrentUser() user: AuthUser, @Body() dto: CreateProfileDto) { return this.profiles.create(user.sub, dto); }
  @Patch(':id') update(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() dto: UpdateProfileDto) { return this.profiles.update(user.sub, id, dto); }
  @Get(':id/progress') progress(@CurrentUser() user: AuthUser, @Param('id') id: string) { return this.profiles.progress(user.sub, id); }
}
