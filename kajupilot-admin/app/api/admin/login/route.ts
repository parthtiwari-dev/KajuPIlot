import { NextRequest, NextResponse } from 'next/server';
import { ADMIN_COOKIE_NAME, adminApiUrl } from '@/lib/admin-api';
import { adminRedirectUrl } from '@/lib/admin-redirect';

export async function POST(request: NextRequest) {
  const formData = await request.formData();
  const username = String(formData.get('username') ?? '');
  const secret = String(formData.get('secret') ?? '');

  const response = await fetch(adminApiUrl('/admin/auth/login'), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, secret }),
  });

  if (!response.ok) {
    return NextResponse.redirect(adminRedirectUrl(request, '/login?error=1'), {
      status: 303,
    });
  }

  const data = (await response.json()) as {
    adminToken: string;
    expiresInSeconds?: number;
  };
  const redirectResponse = NextResponse.redirect(adminRedirectUrl(request, '/'), {
    status: 303,
  });
  redirectResponse.cookies.set(ADMIN_COOKIE_NAME, data.adminToken, {
    httpOnly: true,
    sameSite: 'lax',
    secure: request.nextUrl.protocol === 'https:',
    maxAge: data.expiresInSeconds ?? 60 * 60 * 12,
    path: '/',
  });

  return redirectResponse;
}
