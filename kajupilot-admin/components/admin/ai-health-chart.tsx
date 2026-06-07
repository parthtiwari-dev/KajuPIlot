'use client';

import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip } from 'recharts';

const colors = {
  confirmed: '#34D399',
  unconfirmed: '#FBBF24',
  errors: '#F87171',
};

export function AiHealthChart({
  confirmed,
  unconfirmed,
  errors,
}: {
  confirmed: number;
  unconfirmed: number;
  errors: number;
}) {
  const data = [
    { name: 'Confirmed', value: confirmed, fill: colors.confirmed },
    { name: 'Unconfirmed', value: unconfirmed, fill: colors.unconfirmed },
    { name: 'Errors', value: errors, fill: colors.errors },
  ].filter((item) => item.value > 0);

  if (data.length === 0) {
    return (
      <div className="flex h-44 items-center justify-center rounded-[8px] border border-dashed border-border text-sm text-[#7878A0]">
        No AI parses yet
      </div>
    );
  }

  return (
    <div className="h-44">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie data={data} innerRadius={42} outerRadius={70} dataKey="value" stroke="none">
            {data.map((item) => (
              <Cell key={item.name} fill={item.fill} />
            ))}
          </Pie>
          <Tooltip
            contentStyle={{
              background: '#1A1A26',
              border: '1px solid #28283C',
              borderRadius: 8,
              color: '#EEEEF4',
            }}
          />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}
