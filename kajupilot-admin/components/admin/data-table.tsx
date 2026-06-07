import { shortText } from '@/lib/admin-format';

export function DataTable({
  columns,
  rows,
  empty,
}: {
  columns: Array<{ key: string; label: string; render?: (row: Record<string, unknown>) => React.ReactNode }>;
  rows: Record<string, unknown>[];
  empty: string;
}) {
  if (rows.length === 0) {
    return (
      <div className="rounded-[8px] border border-dashed border-border p-5 text-sm text-[#7878A0]">
        {empty}
      </div>
    );
  }

  return (
    <div className="overflow-x-auto rounded-[8px] border border-border">
      <table className="min-w-full divide-y divide-border text-left text-sm">
        <thead className="bg-elevated/60 text-xs uppercase tracking-[0.12em] text-[#7878A0]">
          <tr>
            {columns.map((column) => (
              <th key={column.key} className="px-3 py-3 font-semibold">
                {column.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-border">
          {rows.map((row, index) => (
            <tr key={(row.id as string | undefined) ?? index} className="align-top">
              {columns.map((column) => (
                <td key={column.key} className="px-3 py-3 text-[#C9C9D8]">
                  {column.render ? column.render(row) : shortText(String(row[column.key] ?? '-'), 72)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
