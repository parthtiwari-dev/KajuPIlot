import { Role } from "@prisma/client";

export interface AuthenticatedUser {
  id: string;
  role: Role;
  name: string;
  businessName: string | null;
}
