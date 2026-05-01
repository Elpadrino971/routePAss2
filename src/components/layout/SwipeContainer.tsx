'use client';

import { useRef } from 'react';
import { useRouter, usePathname } from 'next/navigation';

const ORDER = ['/home', '/transport', '/location', '/map', '/account'];

interface SwipeContainerProps {
  children: React.ReactNode;
}

/**
 * Conteneur swipe horizontal entre les 5 sections principales.
 * Détecte un swipe gauche/droite et navigue vers la section voisine.
 */
export function SwipeContainer({ children }: SwipeContainerProps) {
  const router = useRouter();
  const pathname = usePathname();
  const startX = useRef<number | null>(null);
  const startY = useRef<number | null>(null);

  function onTouchStart(e: React.TouchEvent) {
    startX.current = e.touches[0]?.clientX ?? null;
    startY.current = e.touches[0]?.clientY ?? null;
  }

  function onTouchEnd(e: React.TouchEvent) {
    if (startX.current === null || startY.current === null) return;
    const endX = e.changedTouches[0]?.clientX ?? startX.current;
    const endY = e.changedTouches[0]?.clientY ?? startY.current;
    const dx = endX - startX.current;
    const dy = endY - startY.current;

    startX.current = null;
    startY.current = null;

    // Seuil : 80px horizontal ET dominante horizontale
    if (Math.abs(dx) < 80 || Math.abs(dx) < Math.abs(dy) * 1.5) return;

    const currentIndex = ORDER.findIndex((p) => pathname.startsWith(p));
    if (currentIndex === -1) return;

    const target =
      dx < 0
        ? ORDER[Math.min(currentIndex + 1, ORDER.length - 1)]
        : ORDER[Math.max(currentIndex - 1, 0)];

    if (target && target !== ORDER[currentIndex]) {
      router.push(target);
    }
  }

  return (
    <div onTouchStart={onTouchStart} onTouchEnd={onTouchEnd} className="min-h-dvh">
      {children}
    </div>
  );
}
