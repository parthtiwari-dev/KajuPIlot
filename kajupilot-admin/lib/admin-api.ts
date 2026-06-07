import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';

export const ADMIN_COOKIE_NAME = 'kajupilot_admin';

export function adminApiUrl(path: string) {
  const baseUrl =
    process.env.ADMIN_API_URL ??
    process.env.NEXT_PUBLIC_API_URL ??
    'http://localhost:3000/api/v1';
  return `${baseUrl.replace(/\/$/, '')}${path}`;
}

export async function getAdminToken() {
  const cookieStore = await cookies();
  return cookieStore.get(ADMIN_COOKIE_NAME)?.value ?? null;
}

export async function requireAdminToken() {
  const token = await getAdminToken();
  if (!token) {
    redirect('/login');
  }
  return token;
}

export async function adminFetch<T>(path: string, init?: RequestInit) {
  const token = await requireAdminToken();
  const response = await fetch(adminApiUrl(path), {
    ...init,
    cache: 'no-store',
    headers: {
      Accept: 'application/json',
      ...(init?.headers ?? {}),
      Authorization: `Bearer ${token}`,
    },
  });

  if (response.status === 401) {
    redirect('/login');
  }

  if (!response.ok) {
    throw new Error(`Admin API failed: ${response.status}`);
  }

  return (await response.json()) as T;
}
