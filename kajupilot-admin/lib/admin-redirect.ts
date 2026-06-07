import { NextRequest } from 'next/server';

export function adminRedirectUrl(request: NextRequest, path: string) {
  const host =
    request.headers.get('x-forwarded-host') ??
    request.headers.get('host') ??
    request.nextUrl.host;
  const protocol =
    request.headers.get('x-forwarded-proto') ??
    (host.startsWith('localhost') || host.startsWith('127.0.0.1')
      ? 'http'
      : request.nextUrl.protocol.replace(':', ''));

  return new URL(path, `${protocol}://${host}`);
}
