'use client';

import { useEffect } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { X } from 'lucide-react';
import { cn } from '@/lib/utils';

interface RPBottomSheetProps {
  open: boolean;
  onClose: () => void;
  title?: string;
  children: React.ReactNode;
  className?: string;
}

/** Drawer mobile-first qui monte depuis le bas. */
export function RPBottomSheet({
  open,
  onClose,
  title,
  children,
  className,
}: RPBottomSheetProps) {
  useEffect(() => {
    if (!open) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = prev;
    };
  }, [open]);

  return (
    <AnimatePresence>
      {open ? (
        <>
          <motion.div
            key="backdrop"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 z-40 bg-rp-black/70 backdrop-blur-sm"
          />
          <motion.div
            key="sheet"
            initial={{ y: '100%' }}
            animate={{ y: 0 }}
            exit={{ y: '100%' }}
            transition={{ type: 'spring', damping: 30, stiffness: 300 }}
            drag="y"
            dragConstraints={{ top: 0, bottom: 0 }}
            dragElastic={{ top: 0, bottom: 0.4 }}
            onDragEnd={(_e, info) => {
              if (info.offset.y > 120 || info.velocity.y > 500) onClose();
            }}
            className={cn(
              'fixed inset-x-0 bottom-0 z-50 max-h-[90dvh] overflow-y-auto rounded-t-3xl border-t border-rp-border bg-rp-dark shadow-rp',
              className
            )}
          >
            <div className="sticky top-0 z-10 bg-rp-dark/80 backdrop-blur">
              <div className="flex flex-col items-center pt-2">
                <span className="h-1 w-10 rounded-full bg-rp-border" />
              </div>
              {title ? (
                <div className="flex items-center justify-between px-5 pb-3 pt-3">
                  <h2 className="font-display text-lg text-rp-white">{title}</h2>
                  <button
                    type="button"
                    onClick={onClose}
                    aria-label="Fermer"
                    className="rounded-full p-1.5 text-rp-gray hover:bg-rp-dark-2 hover:text-rp-white"
                  >
                    <X className="h-5 w-5" />
                  </button>
                </div>
              ) : null}
            </div>
            <div className="px-5 pb-8">{children}</div>
          </motion.div>
        </>
      ) : null}
    </AnimatePresence>
  );
}
