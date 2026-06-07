import Link from 'next/link';
import { AdminShell } from '@/components/admin/admin-shell';
import { adminFetch } from '@/lib/admin-api';
import { formatDateTime, shortText, statusClass } from '@/lib/admin-format';

type UserOption = {
  id: string;
  name: string;
};

type AiLog = {
  id: string;
  userId: string;
  rawInput: string;
  parsedJson: unknown;
  confirmed: boolean;
  error: string | null;
  provider: string | null;
  model: string | null;
  createdAt: string;
  user: UserOption;
};

type AiLogResponse = {
  page: number;
  pageSize: number;
  total: number;
  totalPages: number;
  items: AiLog[];
};

type AiLogsPageProps = {
  searchParams?: Promise<{
    userId?: string;
    status?: string;
    from?: string;
    to?: string;
    page?: string;
  }>;
};

export default async function AiLogsPage({ searchParams }: AiLogsPageProps) {
  const params = (await searchParams) ?? {};
  const query = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value) {
      query.set(key, value);
    }
  }

  const [users, logs] = await Promise.all([
    adminFetch<UserOption[]>('/admin/users'),
    adminFetch<AiLogResponse>(`/admin/ai-logs?${query.toString()}`),
  ]);

  return (
    <AdminShell active="ai-logs">
      <div className="flex flex-col gap-6">
        <header className="border-b border-border pb-5">
          <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[#7878A0]">
            AI audit trail
          </p>
          <h2 className="mt-1 text-3xl font-semibold">AI Logs</h2>
          <p className="mt-2 text-sm text-[#A7A3C4]">
            Raw input, parsed JSON, confirmation state, provider, model, and errors.
          </p>
        </header>

        <form className="grid gap-3 rounded-[8px] border border-border bg-card p-4 md:grid-cols-5">
          <label className="text-sm text-[#A7A3C4]">
            User
            <select
              name="userId"
              defaultValue={params.userId ?? ''}
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
            Status
            <select
              name="status"
              defaultValue={params.status ?? 'all'}
              className="mt-1 w-full rounded-[8px] border border-border bg-background px-3 py-2 text-[#EEEEF4]"
            >
              <option value="all">All</option>
              <option value="confirmed">Confirmed</option>
              <option value="unconfirmed">Unconfirmed</option>
              <option value="errors">Errors</option>
            </select>
          </label>
          <label className="text-sm text-[#A7A3C4]">
            From
            <input
              type="date"
              name="from"
              defaultValue={params.from ?? ''}
              className="mt-1 w-full rounded-[8px] border border-border bg-background px-3 py-2 text-[#EEEEF4]"
            />
          </label>
          <label className="text-sm text-[#A7A3C4]">
            To
            <input
              type="date"
              name="to"
              defaultValue={params.to ?? ''}
              className="mt-1 w-full rounded-[8px] border border-border bg-background px-3 py-2 text-[#EEEEF4]"
            />
          </label>
          <button className="mt-6 rounded-[8px] border border-border bg-elevated px-3 py-2 text-sm">
            Filter
          </button>
        </form>

        <section className="rounded-[8px] border border-border bg-card p-4">
          <div className="mb-4 flex items-center justify-between">
            <h3 className="font-semibold">{logs.total} parse logs</h3>
            <p className="text-sm text-[#7878A0]">
              Page {logs.page} of {logs.totalPages}
            </p>
          </div>
          <div className="space-y-3">
            {logs.items.length === 0 ? (
              <div className="rounded-[8px] border border-dashed border-border p-5 text-sm text-[#7878A0]">
                No AI logs match these filters.
              </div>
            ) : (
              logs.items.map((log) => (
                <details key={log.id} className="rounded-[8px] border border-border bg-background p-3">
                  <summary className="cursor-pointer">
                    <div className="inline-flex w-full flex-col gap-2 md:flex-row md:items-center md:justify-between">
                      <div>
                        <p className="font-semibold">{shortText(log.rawInput, 120)}</p>
                        <p className="mt-1 text-xs text-[#7878A0]">
                          <Link href={`/users/${log.userId}`} className="text-accent hover:underline">
                            {log.user.name}
                          </Link>{' '}
                          · {formatDateTime(log.createdAt)} · {log.provider ?? '-'} / {log.model ?? '-'}
                        </p>
                      </div>
                      <span className={`w-fit rounded-full border px-2 py-0.5 text-xs ${statusClass(log.error ? 'ERROR' : log.confirmed ? 'CONFIRMED' : 'OPEN')}`}>
                        {log.error ? 'ERROR' : log.confirmed ? 'CONFIRMED' : 'OPEN'}
                      </span>
                    </div>
                  </summary>
                  <div className="mt-3 grid gap-3 xl:grid-cols-2">
                    <pre className="max-h-96 overflow-auto rounded-[8px] bg-card p-3 text-xs text-[#C9C9D8]">
                      {JSON.stringify(log.parsedJson, null, 2)}
                    </pre>
                    <pre className="max-h-96 overflow-auto rounded-[8px] bg-card p-3 text-xs text-[#C9C9D8]">
                      {log.error ?? 'No parse error recorded.'}
                    </pre>
                  </div>
                </details>
              ))
            )}
          </div>
          <div className="mt-4 flex gap-2">
            {logs.page > 1 ? (
              <Link
                href={`/ai-logs?${pageQuery(params, logs.page - 1)}`}
                className="rounded-[8px] border border-border bg-elevated px-3 py-2 text-sm"
              >
                Previous
              </Link>
            ) : null}
            {logs.page < logs.totalPages ? (
              <Link
                href={`/ai-logs?${pageQuery(params, logs.page + 1)}`}
                className="rounded-[8px] border border-border bg-elevated px-3 py-2 text-sm"
              >
                Next
              </Link>
            ) : null}
          </div>
        </section>
      </div>
    </AdminShell>
  );
}

function pageQuery(params: Record<string, string | undefined>, page: number) {
  const query = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value && key !== 'page') {
      query.set(key, value);
    }
  }
  query.set('page', String(page));
  return query.toString();
}
