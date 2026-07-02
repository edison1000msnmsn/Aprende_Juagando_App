import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { FastifyRequest } from 'fastify';
import type { AuthUser } from './auth-user';

export const CurrentUser = createParamDecorator((_data: unknown, context: ExecutionContext): AuthUser => {
  return (context.switchToHttp().getRequest<FastifyRequest>() as FastifyRequest & { user: AuthUser }).user;
});
