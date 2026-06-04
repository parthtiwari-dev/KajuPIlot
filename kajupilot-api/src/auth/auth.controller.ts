import {
  Body,
  Controller,
  Get,
  Headers,
  Post,
  UnauthorizedException,
} from "@nestjs/common";
import { AuthService } from "./auth.service";
import { SetupAuthDto } from "./dto/setup-auth.dto";

@Controller("auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post("setup")
  setup(@Body() dto: SetupAuthDto) {
    return this.authService.setupOwner(dto);
  }

  @Get("me")
  async me(@Headers("authorization") authorization?: string) {
    const token = authorization?.replace(/^Bearer\s+/i, "").trim();
    if (!token) {
      throw new UnauthorizedException("Missing bearer token");
    }

    return this.authService.getCurrentUser(token);
  }
}
