import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { randomUUID } from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { SetupAuthDto } from './dto/setup-auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {}

  async setupOwner(dto: SetupAuthDto) {
    const expectedCode = this.configService.get<string>('ADMIN_SETUP_CODE');
    if (!expectedCode || dto.setupCode !== expectedCode) {
      throw new UnauthorizedException('Invalid setup code');
    }

    const existingOwner = await this.prisma.user.findFirst({
      where: { role: 'OWNER' },
      orderBy: { createdAt: 'asc' },
    });

    if (existingOwner) {
      return {
        userId: existingOwner.id,
        deviceToken: existingOwner.deviceToken,
      };
    }

    const user = await this.prisma.user.create({
      data: {
        name: dto.name ?? 'Owner',
        businessName: dto.businessName,
        deviceToken: randomUUID(),
        role: 'OWNER',
      },
    });

    return {
      userId: user.id,
      deviceToken: user.deviceToken,
    };
  }

  async getCurrentUser(deviceToken: string) {
    const user = await this.prisma.user.findUnique({
      where: { deviceToken },
      select: {
        id: true,
        name: true,
        businessName: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid device token');
    }

    return user;
  }
}
