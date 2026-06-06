import { DealStatus, Role } from "@prisma/client";
import { AuthenticatedUser } from "../auth/types/authenticated-user";
import { DealsController } from "./deals.controller";
import { DealsService } from "./deals.service";

describe("DealsController", () => {
  let controller: DealsController;
  let dealsService: {
    list: jest.Mock;
    create: jest.Mock;
    get: jest.Mock;
    update: jest.Mock;
    updateStatus: jest.Mock;
    remove: jest.Mock;
  };
  const user: AuthenticatedUser = {
    id: "user-1",
    role: Role.OWNER,
    name: "Owner",
    businessName: null,
  };

  beforeEach(() => {
    dealsService = {
      list: jest.fn(),
      create: jest.fn(),
      get: jest.fn(),
      update: jest.fn(),
      updateStatus: jest.fn(),
      remove: jest.fn(),
    };
    controller = new DealsController(dealsService as unknown as DealsService);
  });

  it("scopes list to the current user", async () => {
    dealsService.list.mockResolvedValueOnce([]);

    await controller.list(user, { status: DealStatus.CONFIRMED });

    expect(dealsService.list).toHaveBeenCalledWith(user, {
      status: DealStatus.CONFIRMED,
    });
  });

  it("passes create body to the service", async () => {
    const dto = {
      partyId: "a227f4ef-f302-41a8-9139-4803f94cda3b",
      items: [
        {
          grade: "W320",
          quantityText: "10 balti",
          totalAmount: "39000.00",
        },
      ],
      totalAmount: "39000.00",
      syncId: "sync-1",
    };
    dealsService.create.mockResolvedValueOnce({ id: "deal-1" });

    await controller.create(user, dto);

    expect(dealsService.create).toHaveBeenCalledWith(user, dto);
  });

  it("passes status updates to the service", async () => {
    dealsService.updateStatus.mockResolvedValueOnce({ id: "deal-1" });

    await controller.updateStatus(user, "deal-1", {
      status: DealStatus.DELIVERED,
    });

    expect(dealsService.updateStatus).toHaveBeenCalledWith(
      user,
      "deal-1",
      DealStatus.DELIVERED,
    );
  });
});
