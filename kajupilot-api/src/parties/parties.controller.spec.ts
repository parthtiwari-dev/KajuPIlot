import { Role } from "@prisma/client";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { PartiesController } from "./parties.controller";
import { PartiesService } from "./parties.service";

describe("PartiesController", () => {
  let controller: PartiesController;
  let partiesService: {
    list: jest.Mock;
    create: jest.Mock;
    get: jest.Mock;
    update: jest.Mock;
    remove: jest.Mock;
    ledger: jest.Mock;
    history: jest.Mock;
  };
  const user: AuthenticatedUser = {
    id: "user-1",
    role: Role.OWNER,
    name: "Owner",
    businessName: null,
  };

  beforeEach(() => {
    partiesService = {
      list: jest.fn(),
      create: jest.fn(),
      get: jest.fn(),
      update: jest.fn(),
      remove: jest.fn(),
      ledger: jest.fn(),
      history: jest.fn(),
    };
    controller = new PartiesController(
      partiesService as unknown as PartiesService,
    );
  });

  it("scopes list to the current user", async () => {
    partiesService.list.mockResolvedValueOnce([]);

    await controller.list(user, { search: "amit" });

    expect(partiesService.list).toHaveBeenCalledWith(user, { search: "amit" });
  });

  it("passes create body to the service", async () => {
    const dto = { name: "Amit", syncId: "sync-1" };
    partiesService.create.mockResolvedValueOnce({ id: "party-1" });

    await controller.create(user, dto);

    expect(partiesService.create).toHaveBeenCalledWith(user, dto);
  });
});
