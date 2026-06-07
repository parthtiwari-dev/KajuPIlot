type LoginPageProps = {
  searchParams?: Promise<{ error?: string }>;
};

export default async function LoginPage({ searchParams }: LoginPageProps) {
  const params = await searchParams;
  const hasError = params?.error === '1';

  return (
    <main className="flex min-h-screen items-center justify-center bg-background px-5 text-[#EEEEF4]">
      <section className="w-full max-w-sm rounded-[8px] border border-border bg-card p-6">
        <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[#7878A0]">
          KajuPilot Admin
        </p>
        <h1 className="mt-2 text-2xl font-semibold">Login</h1>
        <p className="mt-2 text-sm text-[#A7A3C4]">
          Use the private admin credentials from your environment.
        </p>
        {hasError ? (
          <div className="mt-4 rounded-[8px] border border-danger/30 bg-danger/10 px-3 py-2 text-sm text-danger">
            Invalid admin username or secret.
          </div>
        ) : null}
        <form action="/api/admin/login" method="post" className="mt-5 space-y-4">
          <label className="block text-sm">
            <span className="text-[#A7A3C4]">Admin user</span>
            <input
              name="username"
              autoComplete="username"
              className="mt-2 w-full rounded-[8px] border border-border bg-background px-3 py-2 text-[#EEEEF4] outline-none focus:border-accent"
              required
            />
          </label>
          <label className="block text-sm">
            <span className="text-[#A7A3C4]">Admin secret</span>
            <input
              name="secret"
              type="password"
              autoComplete="current-password"
              className="mt-2 w-full rounded-[8px] border border-border bg-background px-3 py-2 text-[#EEEEF4] outline-none focus:border-accent"
              required
            />
          </label>
          <button
            type="submit"
            className="w-full rounded-[8px] bg-accent px-4 py-2 font-semibold text-background transition hover:brightness-110"
          >
            Open admin
          </button>
        </form>
      </section>
    </main>
  );
}
