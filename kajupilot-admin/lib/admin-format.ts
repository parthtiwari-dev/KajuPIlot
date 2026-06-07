export function formatRupees(value: string | number | null | undefined) {
  const amount = Number(value ?? 0);
  return new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    maximumFractionDigits: 0,
  }).format(Number.isFinite(amount) ? amount : 0);
}

export function formatDateTime(value: string | null | undefined) {
  if (!value) {
    return '-';
  }
  return new Intl.DateTimeFormat('en-IN', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(new Date(value));
}

export function formatDate(value: string | null | undefined) {
  if (!value) {
    return '-';
  }
  return new Intl.DateTimeFormat('en-IN', {
    dateStyle: 'medium',
  }).format(new Date(value));
}

export function shortText(value: string | null | undefined, length = 84) {
  if (!value) {
    return '-';
  }
  return value.length > length ? `${value.slice(0, length - 1)}...` : value;
}

export function statusClass(value: string | null | undefined) {
  const status = value?.toUpperCase();
  if (status?.includes('ERROR') || status?.includes('RISK')) {
    return 'border-danger/30 bg-danger/10 text-danger';
  }
  if (status?.includes('CONFIRMED') || status?.includes('DONE')) {
    return 'border-success/30 bg-success/10 text-success';
  }
  if (status?.includes('PENDING') || status?.includes('OPEN')) {
    return 'border-warning/30 bg-warning/10 text-warning';
  }
  return 'border-border bg-elevated text-[#C9C9D8]';
}
