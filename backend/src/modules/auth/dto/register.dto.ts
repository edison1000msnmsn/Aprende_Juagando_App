import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, MaxLength, MinLength } from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'madre.apoderado@example.com' })
  @IsEmail()
  @MaxLength(160)
  email!: string;

  @ApiProperty({ minLength: 10, example: 'AprendeSeguro123!' })
  @IsString()
  @MinLength(10)
  @MaxLength(128)
  password!: string;
}
