import { Role } from "@prisma/client";

export interface DeviceTokenPayload {
  sub: string;
  role: Role;
  typ: "device";
}
