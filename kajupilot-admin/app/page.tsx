import { Activity, BrainCircuit, IndianRupee, Users } from 'lucide-react';

const stats = [
  { label: 'Pending collection', value: 'Rs 0', icon: IndianRupee },
  { label: 'Calls today', value: '0', icon: Activity },
  { label: 'Parties tracked', value: '0', icon: Users },
  { label: 'AI parses today', value: '0', icon: BrainCircuit },
];

export default function AdminOverviewPage() {
  return (
    <main className="min-h-screen bg-background text-[#EEEEF4]">
      <section className="mx-auto flex w-full max-w-7xl flex-col gap-6 px-6 py-8">
        <header className="flex flex-col gap-2 border-b border-border pb-5">
          <p className="text-sm font-medium uppercase tracking-[0.18em] text-[#7878A0]">
            KajuPilot Admin
          </p>
          <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <h1 className="text-3xl font-semibold text-[#EEEEF4]">Overview</h1>
              <p className="mt-1 max-w-2xl text-sm text-[#7878A0]">
                Private operational visibility for the trader's deals, money, calls,
                and AI activity.
              </p>
            </div>
            <div className="rounded-md border border-border bg-card px-3 py-2 text-sm text-[#7878A0]">
              API: {process.env.NEXT_PUBLIC_API_URL ?? 'not configured'}
            </div>
          </div>
        </header>

        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {stats.map((stat) => (
            <div key={stat.label} className="rounded-lg border border-border bg-card p-4">
              <div className="flex items-center justify-between gap-3">
                <p className="text-sm text-[#7878A0]">{stat.label}</p>
                <stat.icon className="h-5 w-5 text-accent" aria-hidden="true" />
              </div>
              <p className="mt-3 font-mono text-2xl font-semibold text-[#EEEEF4]">
                {stat.value}
              </p>
            </div>
          ))}
        </div>

        <div className="grid gap-4 lg:grid-cols-[1.4fr_1fr]">
          <section className="rounded-lg border border-border bg-card p-5">
            <h2 className="text-lg font-semibold">Activity timeline</h2>
            <div className="mt-5 rounded-md border border-dashed border-[#36366A] p-6 text-sm text-[#7878A0]">
              No activity loaded yet. Connect the API and admin auth flow to populate
              today's calls, payments, deals, and parse logs.
            </div>
          </section>

          <section className="rounded-lg border border-border bg-card p-5">
            <h2 className="text-lg font-semibold">Setup checklist</h2>
            <div className="mt-4 space-y-3 text-sm text-[#C9C9D8]">
              <p>1. Configure `.env` secrets.</p>
              <p>2. Run Prisma migrations.</p>
              <p>3. Complete owner device setup from the APK.</p>
              <p>4. Wire dashboard API queries behind admin auth.</p>
            </div>
          </section>
        </div>
      </section>
    </main>
  );
}
