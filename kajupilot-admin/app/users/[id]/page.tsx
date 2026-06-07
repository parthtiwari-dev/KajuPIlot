import Link from 'next/link';
import { AdminShell } from '@/components/admin/admin-shell';
import { DataTable } from '@/components/admin/data-table';
import { adminFetch } from '@/lib/admin-api';
import {
  formatDate,
  formatDateTime,
  formatRupees,
  shortText,
  statusClass,
} from '@/lib/admin-format';

type UserDetail = {
  id: string;
  name: string;
  businessName: string | null;
  role: string;
  createdAt: string;
  parties: Record<string, unknown>[];
  deals: Record<string, unknown>[];
  payments: Record<string, unknown>[];
  expenses: Record<string, unknown>[];
  tasks: Record<string, unknown>[];
  callLogs: Record<string, unknown>[];
  aiParseLogs: Record<string, unknown>[];
  timelineToday: Record<string, unknown>[];
};

type ActivityResponse = {
  range: string;
  items: Record<string, unknown>[];
};

type UserPageProps = {
  params: Promise<{ id: string }>;
  searchParams?: Promise<{ range?: 'today' | '7d' | '30d' }>;
};

export default async function UserPage({ params, searchParams }: UserPageProps) {
  const { id } = await params;
  const query = await searchParams;
  const range = query?.range ?? 'today';
  const [user, activity] = await Promise.all([
    adminFetch<UserDetail>(`/admin/users/${id}`),
    adminFetch<ActivityResponse>(`/admin/users/${id}/activity?range=${range}`),
  ]);

  return (
    <AdminShell active="users">
      <div className="flex flex-col gap-6">
        <header className="flex flex-col gap-3 border-b border-border pb-5 md:flex-row md:items-end md:justify-between">
          <div>
            <Link href="/#users" className="text-sm text-accent hover:underline">
              Back to users
            </Link>
            <h2 className="mt-2 text-3xl font-semibold">{user.name}</h2>
            <p className="mt-1 text-sm text-[#A7A3C4]">
              {user.businessName ?? 'No business name'} · {user.role} · joined{' '}
              {formatDate(user.createdAt)}
            </p>
          </div>
          <form className="flex items-end gap-2">
            <label className="text-sm text-[#A7A3C4]">
              Activity range
              <select
                name="range"
                defaultValue={range}
                className="mt-1 block rounded-[8px] border border-border bg-card px-3 py-2 text-[#EEEEF4] outline-none focus:border-accent"
              >
                <option value="today">Today</option>
                <option value="7d">7 days</option>
                <option value="30d">30 days</option>
              </select>
            </label>
            <button className="rounded-[8px] border border-border bg-elevated px-3 py-2 text-sm">
              Apply
            </button>
          </form>
        </header>

        <section className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
          {[
            ['Parties', user.parties.length],
            ['Deals', user.deals.length],
            ['Payments', user.payments.length],
            ['AI logs', user.aiParseLogs.length],
          ].map(([label, value]) => (
            <div key={label} className="rounded-[8px] border border-border bg-card p-4">
              <p className="text-sm text-[#7878A0]">{label}</p>
              <p className="mt-3 font-mono text-2xl font-semibold">{value}</p>
            </div>
          ))}
        </section>

        <section className="rounded-[8px] border border-border bg-card p-4">
          <h3 className="font-semibold">Activity timeline</h3>
          <p className="mt-1 text-sm text-[#7878A0]">
            Everything this user did in the selected range.
          </p>
          <div className="mt-4 space-y-2">
            {activity.items.length === 0 ? (
              <div className="rounded-[8px] border border-dashed border-border p-5 text-sm text-[#7878A0]">
                No activity in this range.
              </div>
            ) : (
              activity.items.map((item) => (
                <div
                  key={`${item.kind}-${item.id}`}
                  className="rounded-[8px] border border-border bg-background px-3 py-3"
                >
                  <div className="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
                    <div>
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="font-semibold">{String(item.title)}</span>
                        <span className={`rounded-full border px-2 py-0.5 text-xs ${statusClass(String(item.status ?? 'OPEN'))}`}>
                          {String(item.status ?? item.kind)}
                        </span>
                      </div>
                      <p className="mt-1 text-xs text-[#7878A0]">
                        {formatDateTime(String(item.occurredAt))}
                      </p>
                    </div>
                    {item.amount ? (
                      <p className="font-mono text-sm text-success">
                        {formatRupees(String(item.amount))}
                      </p>
                    ) : null}
                  </div>
                </div>
              ))
            )}
          </div>
        </section>

        <section className="grid gap-4 xl:grid-cols-2">
          <Panel title="Parties">
            <DataTable
              empty="No parties."
              rows={user.parties}
              columns={[
                { key: 'name', label: 'Name' },
                { key: 'phone', label: 'Phone' },
                { key: 'type', label: 'Type' },
                { key: 'trustTag', label: 'Trust' },
              ]}
            />
          </Panel>

          <Panel title="Deals">
            <DataTable
              empty="No deals."
              rows={user.deals}
              columns={[
                {
                  key: 'party',
                  label: 'Party',
                  render: (row) => String((row.party as Record<string, unknown>)?.name ?? '-'),
                },
                {
                  key: 'items',
                  label: 'Items',
                  render: (row) =>
                    ((row.items as Record<string, unknown>[] | undefined) ?? [])
                      .map((item) => `${item.grade} ${item.quantityText}`)
                      .join(', ') || String(row.cashewGrade ?? '-'),
                },
                {
                  key: 'totalAmount',
                  label: 'Total',
                  render: (row) => formatRupees(String(row.totalAmount)),
                },
                { key: 'status', label: 'Status' },
              ]}
            />
          </Panel>

          <Panel title="Payments">
            <DataTable
              empty="No payments."
              rows={user.payments}
              columns={[
                {
                  key: 'party',
                  label: 'Party',
                  render: (row) => String((row.party as Record<string, unknown>)?.name ?? '-'),
                },
                { key: 'type', label: 'Type' },
                {
                  key: 'amount',
                  label: 'Amount',
                  render: (row) => formatRupees(String(row.amount)),
                },
                {
                  key: 'paymentDate',
                  label: 'Date',
                  render: (row) => formatDate(String(row.paymentDate)),
                },
              ]}
            />
          </Panel>

          <Panel title="Expenses">
            <DataTable
              empty="No expenses."
              rows={user.expenses}
              columns={[
                { key: 'category', label: 'Category' },
                { key: 'scope', label: 'Scope' },
                {
                  key: 'amount',
                  label: 'Amount',
                  render: (row) => formatRupees(String(row.amount)),
                },
                {
                  key: 'expenseDate',
                  label: 'Date',
                  render: (row) => formatDate(String(row.expenseDate)),
                },
              ]}
            />
          </Panel>

          <Panel title="Tasks">
            <DataTable
              empty="No tasks."
              rows={user.tasks}
              columns={[
                { key: 'title', label: 'Title' },
                { key: 'type', label: 'Type' },
                { key: 'status', label: 'Status' },
                {
                  key: 'scheduledAt',
                  label: 'Scheduled',
                  render: (row) => formatDateTime(String(row.scheduledAt)),
                },
              ]}
            />
          </Panel>

          <Panel title="Call Logs">
            <DataTable
              empty="No call logs."
              rows={user.callLogs}
              columns={[
                {
                  key: 'party',
                  label: 'Party',
                  render: (row) => String((row.party as Record<string, unknown>)?.name ?? '-'),
                },
                { key: 'outcome', label: 'Outcome' },
                {
                  key: 'promisedAmount',
                  label: 'Promised',
                  render: (row) =>
                    row.promisedAmount ? formatRupees(String(row.promisedAmount)) : '-',
                },
                {
                  key: 'createdAt',
                  label: 'Logged',
                  render: (row) => formatDateTime(String(row.createdAt)),
                },
              ]}
            />
          </Panel>
        </section>

        <section className="rounded-[8px] border border-border bg-card p-4">
          <h3 className="font-semibold">Raw AI parse sessions</h3>
          <div className="mt-4 space-y-3">
            {user.aiParseLogs.length === 0 ? (
              <div className="rounded-[8px] border border-dashed border-border p-5 text-sm text-[#7878A0]">
                No AI parse logs.
              </div>
            ) : (
              user.aiParseLogs.slice(0, 20).map((log) => (
                <details key={String(log.id)} className="rounded-[8px] border border-border bg-background p-3">
                  <summary className="cursor-pointer text-sm font-semibold">
                    {shortText(String(log.rawInput ?? '-'), 120)}
                  </summary>
                  <div className="mt-3 grid gap-3 xl:grid-cols-2">
                    <pre className="overflow-auto rounded-[8px] bg-card p-3 text-xs text-[#C9C9D8]">
                      {JSON.stringify(log.parsedJson, null, 2)}
                    </pre>
                    <pre className="overflow-auto rounded-[8px] bg-card p-3 text-xs text-[#C9C9D8]">
                      {JSON.stringify(log.confirmedJson ?? { error: log.error }, null, 2)}
                    </pre>
                  </div>
                </details>
              ))
            )}
          </div>
        </section>
      </div>
    </AdminShell>
  );
}

function Panel({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="rounded-[8px] border border-border bg-card p-4">
      <h3 className="mb-4 font-semibold">{title}</h3>
      {children}
    </section>
  );
}
