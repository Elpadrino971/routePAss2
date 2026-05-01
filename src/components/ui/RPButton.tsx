'use client';

import { forwardRef, type ButtonHTMLAttributes } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { Loader2 } from 'lucide-react';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  'inline-flex items-center justify-center gap-2 rounded-rp-btn font-medium ' +
    'transition-all duration-200 select-none active:scale-[0.98] ' +
    'disabled:opacity-50 disabled:cursor-not-allowed disabled:active:scale-100 ' +
    'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-rp-gold/40 ' +
    'focus-visible:ring-offset-2 focus-visible:ring-offset-rp-black',
  {
    variants: {
      variant: {
        primary:
          'rp-gradient-gold text-rp-black shadow-rp-gold hover:brightness-110',
        secondary:
          'border border-rp-border bg-rp-dark text-rp-white hover:bg-rp-dark-2 hover:border-rp-gold/40',
        ghost: 'text-rp-white hover:bg-rp-dark-2',
        destructive:
          'bg-rp-danger text-rp-white hover:bg-rp-danger/90',
        outlineGold:
          'border border-rp-gold text-rp-gold hover:bg-rp-gold/10',
      },
      size: {
        sm: 'h-9 px-4 text-sm',
        md: 'h-12 px-6 text-base',
        lg: 'h-14 px-8 text-base',
        icon: 'h-10 w-10',
      },
      block: { true: 'w-full', false: '' },
    },
    defaultVariants: { variant: 'primary', size: 'md', block: false },
  }
);

export interface RPButtonProps
  extends ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  loading?: boolean;
}

export const RPButton = forwardRef<HTMLButtonElement, RPButtonProps>(
  function RPButton(
    { className, variant, size, block, loading, children, disabled, ...props },
    ref
  ) {
    return (
      <button
        ref={ref}
        className={cn(buttonVariants({ variant, size, block }), className)}
        disabled={disabled || loading}
        {...props}
      >
        {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : null}
        {children}
      </button>
    );
  }
);
