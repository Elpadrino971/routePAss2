'use client';

import { forwardRef, useId, useState, type InputHTMLAttributes } from 'react';
import { cn } from '@/lib/utils';

export interface RPInputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  hint?: string;
}

export const RPInput = forwardRef<HTMLInputElement, RPInputProps>(
  function RPInput(
    { label, error, hint, className, type = 'text', id: providedId, value, onFocus, onBlur, ...props },
    ref
  ) {
    const generatedId = useId();
    const id = providedId ?? generatedId;
    const [focused, setFocused] = useState(false);
    const isFloating = focused || (value !== undefined && String(value).length > 0);

    return (
      <div className="w-full">
        <div
          className={cn(
            'relative rounded-rp-input border bg-rp-dark-2 transition-colors',
            error
              ? 'border-rp-danger/60'
              : focused
              ? 'border-rp-gold/60'
              : 'border-rp-border'
          )}
        >
          {label ? (
            <label
              htmlFor={id}
              className={cn(
                'pointer-events-none absolute left-3 transition-all duration-150',
                isFloating
                  ? 'top-1.5 text-[11px] text-rp-gold'
                  : 'top-1/2 -translate-y-1/2 text-sm text-rp-gray'
              )}
            >
              {label}
            </label>
          ) : null}
          <input
            ref={ref}
            id={id}
            type={type}
            value={value}
            onFocus={(e) => {
              setFocused(true);
              onFocus?.(e);
            }}
            onBlur={(e) => {
              setFocused(false);
              onBlur?.(e);
            }}
            className={cn(
              'w-full bg-transparent px-3 text-sm text-rp-white placeholder:text-rp-gray/50 focus:outline-none',
              label ? 'pt-5 pb-1.5' : 'py-3',
              className
            )}
            {...props}
          />
        </div>
        {error ? (
          <p className="mt-1 px-1 text-xs text-rp-danger">{error}</p>
        ) : hint ? (
          <p className="mt-1 px-1 text-xs text-rp-gray">{hint}</p>
        ) : null}
      </div>
    );
  }
);
