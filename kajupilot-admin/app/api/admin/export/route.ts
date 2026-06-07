import { cookies } from 'next/headers';
import { NextRequest, NextResponse } from 'next/server';
import { ADMIN_COOKIE_NAME, adminApiUrl } from '@/lib/admin-api';
import { adminRedirectUrl } from '@/lib/admin-redirect';

export async function GET(request: NextRequest) {
  const token = (await cookies()).get(ADMIN_COOKIE_NAME)?.value;
  if (!token) {
    return NextResponse.redirect(adminRedirectUrl(request, '/login'));
  }

  const response = await fetch(
    adminApiUrl(`/admin/exports?${request.nextUrl.searchParams.toString()}`),
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  const body = await response.text();
  return new NextResponse(body, {
    status: response.status,
    headers: {
      'Content-Type': response.headers.get('Content-Type') ?? 'text/plain',
      'Content-Disposition':
        response.headers.get('Content-Disposition') ?? 'attachment',
    },
  });
}
