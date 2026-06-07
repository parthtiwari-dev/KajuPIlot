import Link from 'next/link';
import { Activity, BrainCircuit, IndianRupee, ReceiptText, Users } from 'lucide-react';
import { AiHealthChart } from '@/components/admin/ai-health-chart';
import { AdminShell } from '@/components/admin/admin-shell';
import { DataTable } from '@/components/admin/data-table';
import { adminFetch } from '@/lib/admin-api';
import { formatDateTime, formatRupees, statusClass } from '@/lib/admin-format';

type Stats = {
  date: string;
  activeUsers: number;
  totalUsers: number;
  dealsCreated: number;
  aiParseCalls: number;
  paymentsLogged: number;
  pendingCollection: string;
  aiParse: {
    total: number;
    confirmed: number;
    unconfirmed: number;
    errors: number;
    successRate: number;
  };
  recentActivity: Record<string, unknown>[];
};

type AdminUser = {
  id: string;
  name: string;
  businessName: string | null;
  role: string;
  createdAt: string;
  _count: Record<string, number>;
};

type OverviewProps = {
  searchParams?: Promise<{ date?: string }>;
};

export default async function AdminOverviewPage({ searchParams }: OverviewProps) {
  const params = await searchParams;
  const date = params?.date ?? new Date().toISOString().slice(0, 10);
  const [stats, users] = await Promise.all([
    adminFetch<Stats>(`/admin/stats?date=${date}`),
    adminFetch<AdminUser[]>('/admin/users'),
  ]);

  const cards = [
    {
      label: 'Pending collection',
      value: formatRupees(stats.pendingCollection),
      icon: IndianRupee,
      tone: 'text-success',
    },
    {
      label: 'Active users',
      value: `${stats.activeUsers}/${stats.totalUsers}`,
      icon: Users,
      tone: 'text-[#EEEEF4]',
    },
    {
      label: 'Deals today',
      value: stats.dealsCreated,
      icon: ReceiptText,
      tone: 'text-[#EEEEF4]',
    },
    {
      label: 'AI parses',
      value: stats.aiParseCalls,
      icon: BrainCircuit,
      tone: 'text-accent',
    },
  ];

  return (
    <AdminShell active="overview">
      <div className="flex flex-col gap-6">
        <header className="flex flex-col gap-4 border-b border-border pb-5 md:flex-row md:items-end md:justify-between">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[#7878A0]">
              System overview
            </p>
            <h2 className="mt-1 text-3xl font-semibold">Admin Dashboard</h2>
            <p className="mt-2 text-sm text-[#A7A3C4]">
              Full visibility into trader data, money flow, and AI activity.
            </p>
          </div>
          <form className="flex items-end gap-2">
            <label className="text-sm text-[#A7A3C4]">
              Date
              <input
                type="date"
                name="date"
                defaultValue={stats.date}
                className="mt-1 block rounded-[8px] border border-border bg-card px-3 py-2 text-[#EEEEF4] outline-none focus:border-accent"
              />
            </label>
            <button className="rounded-[8px] border border-border bg-elevated px-3 py-2 text-sm">
              Refresh
            </button>
          </form>
        </header>

        <section className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
          {cards.map((card) => (
            <div key={card.label} className="rounded-[8px] border border-border bg-card p-4">
              <div className="flex items-center justify-between gap-3">
                <p className="text-sm text-[#7878A0]">{card.label}</p>
                <card.icon className="h-5 w-5 text-accent" aria-hidden="true" />
              </div>
              <p className={`mt-3 font-mono text-2xl font-semibold ${card.tone}`}>
                {card.value}
              </p>
            </div>
          ))}
        </section>

        <section className="grid gap-4 xl:grid-cols-[1.2fr_0.8fr]">
          <div className="rounded-[8px] border border-border bg-card p-4">
            <div className="flex items-center justify-between gap-3">
              <div>
                <h3 className="font-semibold">Today activity</h3>
                <p className="mt-1 text-sm text-[#7878A0]">
                  Deals, payments, tasks, calls, expenses, and AI parse sessions.
                </p>
              </div>
              <Activity className="h-5 w-5 text-accent" aria-hidden="true" />
            </div>
            <div className="mt-4 space-y-2">
              {stats.recentActivity.length === 0 ? (
                <div className="rounded-[8px] border border-dashed border-border p-5 text-sm text-[#7878A0]">
                  No activity recorded for this date.
                </div>
              ) : (
                stats.recentActivity.map((item) => (
                  <div
                    key={`${item.kind}-${item.id}`}
                    className="flex flex-col gap-2 rounded-[8px] border border-border bg-background px-3 py-3 md:flex-row md:items-center md:justify-between"
                  >
                    <div>
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="text-sm font-semibold">{String(item.title)}</span>
                        <span className={`rounded-full border px-2 py-0.5 text-xs ${statusClass(String(item.status ?? 'OPEN'))}`}>
                          {String(item.status ?? item.kind)}
                        </span>
                      </div>
                      <p className="mt-1 text-xs text-[#7878A0]">
                        {String(item.userName)} · {formatDateTime(String(item.occurredAt))}
                      </p>
                    </div>
                    {item.amount ? (
                      <p className="font-mono text-sm text-success">
                        {formatRupees(String(item.amount))}
                      </p>
                    ) : null}
                  </div>
                ))
              )}
            </div>
          </div>

          <div className="rounded-[8px] border border-border bg-card p-4">
            <h3 className="font-semibold">AI parse health</h3>
            <p className="mt-1 text-sm text-[#7878A0]">
              {stats.aiParse.successRate}% confirmed from {stats.aiParse.total} calls.
            </p>
            <AiHealthChart
              confirmed={stats.aiParse.confirmed}
              unconfirmed={stats.aiParse.unconfirmed}
              errors={stats.aiParse.errors}
            />
            <div className="grid grid-cols-3 gap-2 text-center text-xs text-[#A7A3C4]">
              <span>Confirmed {stats.aiParse.confirmed}</span>
              <span>Open {stats.aiParse.unconfirmed}</span>
              <span>Errors {stats.aiParse.errors}</span>
            </div>
          </div>
        </section>

        <section id="users" className="rounded-[8px] border border-border bg-card p-4">
          <div className="mb-4 flex items-center justify-between gap-3">
            <div>
              <h3 className="font-semibold">Users</h3>
              <p className="mt-1 text-sm text-[#7878A0]">Owner/admin records and data volume.</p>
            </div>
          </div>
          <DataTable
            empty="No users found."
            rows={users as unknown as Record<string, unknown>[]}
            columns={[
              {
                key: 'name',
                label: 'User',
                render: (row) => (
                  <Link href={`/users/${row.id}`} className="font-semibold text-accent hover:underline">
                    {String(row.name)}
                  </Link>
                ),
              },
              { key: 'businessName', label: 'Business' },
              { key: 'role', label: 'Role' },
              {
                key: '_count',
                label: 'Records',
                render: (row) => {
                  const count = row._count as Record<string, number>;
                  return `${count.parties ?? 0} parties · ${count.deals ?? 0} deals · ${count.aiParseLogs ?? 0} AI`;
                },
              },
              {
                key: 'createdAt',
                label: 'Created',
                render: (row) => formatDateTime(String(row.createdAt)),
              },
            ]}
          />
        </section>
      </div>
    </AdminShell>
  );
}
