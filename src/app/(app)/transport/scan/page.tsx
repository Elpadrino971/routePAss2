'use client';

import { useRouter } from 'next/navigation';
import { RPQRScanner } from '@/components/ui';

export default function ScanPage() {
  const router = useRouter();
  return (
    <RPQRScanner
      onResult={(text) => {
        // Phase 2 : décoder + rediriger vers le récap de paiement
        // eslint-disable-next-line no-console
        console.log('QR scanned:', text);
      }}
      onClose={() => router.back()}
    />
  );
}
