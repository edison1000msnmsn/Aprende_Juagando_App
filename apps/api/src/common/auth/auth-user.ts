export interface AuthUser {
  sub: string;
  email: string;
  role: 'ADMIN' | 'TEACHER' | 'PARENT';
}
