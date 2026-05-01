import { NextResponse, type NextRequest } from 'next/server';
import { createServerClient, type CookieOptions } from '@supabase/ssr';

/**
 * Middleware Supabase — rafraîchit la session et protège les routes app/provider/admin.
 */
export async function middleware(req: NextRequest) {
  const res = NextResponse.next();

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get: (name: string) => req.cookies.get(name)?.value,
        set: (name: string, value: string, options: CookieOptions) => {
          res.cookies.set({ name, value, ...options });
        },
        remove: (name: string, options: CookieOptions) => {
          res.cookies.set({ name, value: '', ...options });
        },
      },
    }
  );

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { pathname } = req.nextUrl;

  const isProtected =
    pathname.startsWith('/home') ||
    pathname.startsWith('/transport') ||
    pathname.startsWith('/location') ||
    pathname.startsWith('/map') ||
    pathname.startsWith('/wallet') ||
    pathname.startsWith('/account') ||
    pathname.startsWith('/dashboard') ||
    pathname.startsWith('/my-qr') ||
    pathname.startsWith('/validate') ||
    pathname.startsWith('/assets') ||
    pathname.startsWith('/earnings') ||
    pathname.startsWith('/admin') ||
    pathname.startsWith('/onboarding');

  if (isProtected && !user) {
    const redirectUrl = new URL('/login', req.url);
    redirectUrl.searchParams.set('next', pathname);
    return NextResponse.redirect(redirectUrl);
  }

  if ((pathname === '/login' || pathname === '/register') && user) {
    return NextResponse.redirect(new URL('/home', req.url));
  }

  return res;
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)'],
};
