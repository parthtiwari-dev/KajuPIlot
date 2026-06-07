import Link from 'next/link';
import { Activity, BrainCircuit, Download, LayoutDashboard, Users } from 'lucide-react';
import { cn } from '@/lib/utils';

const navItems = [
  { href: '/', label: 'Overview', icon: LayoutDashboard },
  { href: '/ai-logs', label: 'AI logs', icon: BrainCircuit },
  { href: '/exports', label: 'Exports', icon: Download },
];

export function AdminShell({
  active,
  children,
}: {
  active: 'overview' | 'users' | 'ai-logs' | 'exports';
  children: React.ReactNode;
}) {
  return (
    <main className="min-h-screen bg-background text-[#EEEEF4]">
      <div className="mx-auto grid w-full max-w-7xl grid-cols-1 gap-6 px-5 py-6 lg:grid-cols-[240px_1fr]">
        <aside className="h-fit rounded-[8px] border border-border bg-card p-3 lg:sticky lg:top-6">
          <div className="px-2 py-3">
            <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[#7878A0]">
              KajuPilot
            </p>
            <h1 className="mt-1 text-xl font-semibold">Admin</h1>
          </div>
          <nav className="mt-3 space-y-1">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  'flex items-center gap-3 rounded-[8px] px-3 py-2 text-sm text-[#A7A3C4] transition hover:bg-elevated hover:text-[#EEEEF4]',
                  active === item.label.toLowerCase().replace(' ', '-')
                    ? 'bg-elevated text-accent'
                    : '',
                )}
              >
                <item.icon className="h-4 w-4" aria-hidden="true" />
                {item.label}
              </Link>
            ))}
            <Link
              href="/#users"
              className={cn(
                'flex items-center gap-3 rounded-[8px] px-3 py-2 text-sm text-[#A7A3C4] transition hover:bg-elevated hover:text-[#EEEEF4]',
                active === 'users' ? 'bg-elevated text-accent' : '',
              )}
            >
              <Users className="h-4 w-4" aria-hidden="true" />
              Users
            </Link>
          </nav>
          <div className="mt-5 border-t border-border pt-3">
            <a
              href="/api/admin/logout"
              className="flex items-center gap-3 rounded-[8px] px-3 py-2 text-sm text-[#A7A3C4] transition hover:bg-elevated hover:text-[#EEEEF4]"
            >
              <Activity className="h-4 w-4" aria-hidden="true" />
              Logout
            </a>
          </div>
        </aside>
        <section className="min-w-0">{children}</section>
      </div>
    </main>
  );
}
