export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <main className="min-h-dvh bg-rp-black">
      <div className="mx-auto flex min-h-dvh max-w-md flex-col px-6 py-10">
        {children}
      </div>
    </main>
  );
}
