import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'KajuPilot Admin',
  description: 'Private activity and business visibility for KajuPilot.',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body>{children}</body>
    </html>
  );
}
