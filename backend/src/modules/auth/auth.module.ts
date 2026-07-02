import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { JwtAuthGuard } from '../../common/auth/jwt-auth.guard';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Module({
  imports: [JwtModule.register({})],
  controllers: [AuthController],
  providers: [AuthService, JwtAuthGuard],
  exports: [JwtModule, JwtAuthGuard],
})
export class AuthModule {}
