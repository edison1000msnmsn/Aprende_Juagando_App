import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, IsOptional, IsString, Max, MaxLength, Min } from 'class-validator';

export class CreateProfileDto {
  @ApiProperty({ example: 'Valentina', description: 'Apodo, no nombre completo.' })
  @IsString()
  @MaxLength(40)
  nickname!: string;

  @ApiProperty({ minimum: 4, maximum: 8 })
  @IsInt()
  @Min(4)
  @Max(8)
  age!: number;

  @ApiPropertyOptional({ example: '1° primaria' })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  grade?: string;

  @ApiPropertyOptional({ example: 'owl' })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  avatar?: string;
}
