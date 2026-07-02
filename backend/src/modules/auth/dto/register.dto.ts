import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, MaxLength, MinLength } from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'familia@demo.local' })
  @IsEmail()
  @MaxLength(160)
  email!: string;

  @ApiProperty({ minLength: 10, example: 'DemoAprende123!' })
  @IsString()
  @MinLength(10)
  @MaxLength(128)
  password!: string;
}
