import { HttpException, HttpStatus, Injectable } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import Redis from "ioredis";

@Injectable()
export class AiRateLimitService {
  private redis?: Redis;
  private readonly memoryCounts = new Map<
    string,
    { count: number; reset: number }
  >();

  constructor(private readonly configService: ConfigService) {}

  async assertParseAllowed(userId: string) {
    const limit = this.limit();
    const key = `ai:parse:${userId}:${this.hourBucket()}`;

    if (this.redisUrl()) {
      const count = await this.incrementRedis(key);
      if (count > limit) {
        throw new HttpException(
          {
            error: "rate_limited",
            message: "AI parse rate limit reached",
          },
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }
      return;
    }

    const count = this.incrementMemory(key);
    if (count > limit) {
      throw new HttpException(
        {
          error: "rate_limited",
          message: "AI parse rate limit reached",
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }
  }

  private async incrementRedis(key: string) {
    const redis = this.getRedis();
    const count = await redis.incr(key);
    if (count === 1) {
      await redis.expire(key, 60 * 60);
    }
    return count;
  }

  private incrementMemory(key: string) {
    const now = Date.now();
    const current = this.memoryCounts.get(key);
    if (!current || current.reset < now) {
      this.memoryCounts.set(key, { count: 1, reset: now + 60 * 60 * 1000 });
      return 1;
    }

    current.count += 1;
    return current.count;
  }

  private getRedis() {
    this.redis ??= new Redis(this.redisUrl()!, {
      lazyConnect: false,
      maxRetriesPerRequest: 1,
    });
    return this.redis;
  }

  private redisUrl() {
    return this.configService.get<string>("REDIS_URL")?.trim();
  }

  private limit() {
    const rawValue = this.configService
      .get<string>("AI_PARSE_RATE_LIMIT_PER_HOUR")
      ?.trim();
    const value = rawValue ? Number(rawValue) : 20;
    return Number.isFinite(value) && value > 0 ? value : 20;
  }

  private hourBucket() {
    return Math.floor(Date.now() / (60 * 60 * 1000));
  }
}
