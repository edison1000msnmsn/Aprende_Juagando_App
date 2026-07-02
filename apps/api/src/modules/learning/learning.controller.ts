import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { AuthUser } from '../../common/auth/auth-user';
import { CurrentUser } from '../../common/auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { ListContentDto } from './dto/list-content.dto';
import { SubmitAttemptDto } from './dto/submit-attempt.dto';
import { LearningService } from './learning.service';

@ApiTags('learning')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller({ path: '', version: '1' })
export class LearningController {
  constructor(private readonly learning: LearningService) {}

  @Get('modules') modules(@CurrentUser() user: AuthUser, @Query() query: ListContentDto) { return this.learning.modules(user.sub, query.profileId); }
  @Get('modules/:moduleId/levels') levels(@CurrentUser() user: AuthUser, @Param('moduleId') moduleId: string, @Query() query: ListContentDto) { return this.learning.levels(user.sub, moduleId, query.profileId); }
  @Get('activities/:id') activity(@CurrentUser() user: AuthUser, @Param('id') id: string, @Query() query: ListContentDto) { return this.learning.activity(user.sub, id, query.profileId); }
  @Post('activities/:id/attempts') submit(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() dto: SubmitAttemptDto) { return this.learning.submitAttempt(user.sub, id, dto); }
}
