import { NextRequest, NextResponse } from 'next/server';
import { ADMIN_COOKIE_NAME } from '@/lib/admin-api';
import { adminRedirectUrl } from '@/lib/admin-redirect';

export async function GET(request: NextRequest) {
  const response = NextResponse.redirect(adminRedirectUrl(request, '/login'));
  response.cookies.set(ADMIN_COOKIE_NAME, '', {
    httpOnly: true,
    sameSite: 'lax',
    secure: request.nextUrl.protocol === 'https:',
    maxAge: 0,
    path: '/',
  });
  return response;
}
