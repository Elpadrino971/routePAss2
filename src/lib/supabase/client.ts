'use client';

import { createBrowserClient } from '@supabase/ssr';

/** Client Supabase navigateur — utilise les cookies SSR. */
export function createSupabaseBrowser() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
