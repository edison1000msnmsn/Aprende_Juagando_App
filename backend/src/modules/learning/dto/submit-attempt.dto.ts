import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsObject, IsUUID, Max, Min } from 'class-validator';

export class SubmitAttemptDto {
  @ApiProperty()
  @IsUUID()
  profileId!: string;

  @ApiProperty()
  @IsUUID()
  clientAttemptId!: string;

  @ApiProperty({ type: 'object', additionalProperties: true, example: { value: 4 } })
  @IsObject()
  answer!: Record<string, unknown>;

  @ApiProperty({ minimum: 0, maximum: 3600000 })
  @IsInt()
  @Min(0)
  @Max(3_600_000)
  elapsedMs!: number;
}
