import { UnauthorizedException } from "@nestjs/common";
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";

describe("AuthController", () => {
  let controller: AuthController;
  let authService: { getCurrentUser: jest.Mock; setupOwner: jest.Mock };

  beforeEach(() => {
    authService = {
      getCurrentUser: jest.fn(),
      setupOwner: jest.fn(),
    };
    controller = new AuthController(authService as unknown as AuthService);
  });

  it("rejects auth/me without a bearer token", async () => {
    await expect(controller.me()).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it("passes bearer token to auth service", async () => {
    authService.getCurrentUser.mockResolvedValueOnce({ id: "user-1" });

    await expect(controller.me("Bearer signed-token")).resolves.toEqual({
      id: "user-1",
    });
    expect(authService.getCurrentUser).toHaveBeenCalledWith("signed-token");
  });
});
