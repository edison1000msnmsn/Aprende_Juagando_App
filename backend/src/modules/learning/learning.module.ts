import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { ProfilesModule } from '../profiles/profiles.module';
import { LearningController } from './learning.controller';
import { LearningService } from './learning.service';

@Module({ imports: [AuthModule, ProfilesModule], controllers: [LearningController], providers: [LearningService] })
export class LearningModule {}
