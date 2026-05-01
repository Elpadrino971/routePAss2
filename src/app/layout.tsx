import type { Metadata, Viewport } from 'next';
import { Inter, Playfair_Display, JetBrains_Mono } from 'next/font/google';
import './globals.css';

const fontBody = Inter({
  subsets: ['latin'],
  variable: '--font-body',
  display: 'swap',
});

const fontDisplay = Playfair_Display({
  subsets: ['latin'],
  variable: '--font-display',
  display: 'swap',
});

const fontMono = JetBrains_Mono({
  subsets: ['latin'],
  variable: '--font-mono',
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'ROUTEPASS — Infrastructure de paiement',
  description:
    'Scannez, réservez, accédez à vos transports et locations en quelques secondes.',
  applicationName: 'ROUTEPASS',
  manifest: '/manifest.json',
};

export const viewport: Viewport = {
  themeColor: '#08080D',
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  viewportFit: 'cover',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="fr"
      className={`${fontBody.variable} ${fontDisplay.variable} ${fontMono.variable} dark`}
    >
      <body className="min-h-dvh bg-rp-black text-rp-white font-body antialiased">
        {children}
      </body>
    </html>
  );
}
