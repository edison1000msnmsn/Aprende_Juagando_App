import { ApiProperty } from '@nestjs/swagger';
import { IsUUID } from 'class-validator';

export class ListContentDto {
  @ApiProperty()
  @IsUUID()
  profileId!: string;
}
