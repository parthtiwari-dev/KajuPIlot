import { Role } from "@prisma/client";
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

  it("returns the authenticated current user", () => {
    const user = {
      id: "user-1",
      role: Role.OWNER,
      name: "Owner",
      businessName: null,
    };

    expect(controller.me(user)).toEqual(user);
  });
});
