import { AdminShell } from '@/components/admin/admin-shell';
import { adminFetch } from '@/lib/admin-api';

type UserOption = {
  id: string;
  name: string;
};

const tables = [
  ['users', 'Users'],
  ['parties', 'Parties'],
  ['deals', 'Deals'],
  ['dealItems', 'Deal items'],
  ['payments', 'Payments'],
  ['expenses', 'Expenses'],
  ['tasks', 'Tasks'],
  ['callLogs', 'Call logs'],
  ['aiParseLogs', 'AI parse logs'],
];

export default async function ExportsPage() {
  const users = await adminFetch<UserOption[]>('/admin/users');

  return (
    <AdminShell active="exports">
      <div className="flex flex-col gap-6">
        <header className="border-b border-border pb-5">
          <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[#7878A0]">
            Data download
          </p>
          <h2 className="mt-1 text-3xl font-semibold">Exports</h2>
          <p className="mt-2 text-sm text-[#A7A3C4]">
            Download admin-only JSON or CSV by table, user, and date range.
          </p>
        </header>

        <section className="rounded-[8px] border border-border bg-card p-5">
          <form action="/api/admin/export" method="get" className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
            <label className="text-sm text-[#A7A3C4]">
              Table
              <select
                name="table"
                className="mt-1 w-full rounded-[8px] border border-border bg-background px-3 py-2 text-[#EEEEF4]"
                required
              >
                {tables.map(([value, label]) => (
                  <option key={value} value={value}>
                    {label}
                  </option>
                ))}
              </select>
            </label>
            <label className="text-sm text-[#A7A3C4]">
              User
              <select
                name="userId"
                className="mt-1 w-full rounded-[8px] border border-border bg-background px-3 py-2 text-[#EEEEF4]"
              >
                <option value="">All users</option>
                {users.map((user) => (
                  <option key={user.id} value={user.id}>
                    {user.name}
                  </option>
                ))}
              </select>
            </label>
            <label className="text-sm text-[#A7A3C4]">
              Format
              <select
                name="format"
                className="mt-1 w-full rounded-[8px] border border-border bg-background px-3 py-2 text-[#EEEEF4]"
                required
              >
                <option value="csv">CSV</option>
                <option value="json">JSON</option>
              </select>
            </label>
            <label className="text-sm text-[#A7A3C4]">
              From
              <input
                type="date"
                name="from"
                className="mt-1 w-full rounded-[8px] border border-border bg-background px-3 py-2 text-[#EEEEF4]"
              />
            </label>
            <label className="text-sm text-[#A7A3C4]">
              To
              <input
                type="date"
                name="to"
                className="mt-1 w-full rounded-[8px] border border-border bg-background px-3 py-2 text-[#EEEEF4]"
              />
            </label>
            <div className="flex items-end">
              <button
                type="submit"
                className="w-full rounded-[8px] bg-accent px-4 py-2 font-semibold text-background transition hover:brightness-110"
              >
                Download
              </button>
            </div>
          </form>
        </section>

        <section className="rounded-[8px] border border-border bg-card p-5">
          <h3 className="font-semibold">Export rules</h3>
          <div className="mt-3 grid gap-3 text-sm text-[#A7A3C4] md:grid-cols-2">
            <p>Users export never includes device tokens or secrets.</p>
            <p>Deals include bucket-wise deal items as the real item source.</p>
            <p>Payments filter by payment date.</p>
            <p>Expenses filter by expense date.</p>
            <p>Tasks filter by scheduled date.</p>
            <p>AI logs include raw input, parsed JSON, confirmation, and errors.</p>
          </div>
        </section>
      </div>
    </AdminShell>
  );
}
