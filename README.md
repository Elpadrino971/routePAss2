# ROUTEPASS

> **Axen Digital © 2026** — Infrastructure de paiement pour l'économie réelle.

Stack : **Next.js 14** (App Router) · **TypeScript strict** · **Tailwind CSS** · **Supabase** (Auth, Postgres, Storage, Realtime) · **Stripe Connect** · **TTLock** · **Shelly** · **Mapbox** · **Vercel**.

---

## Statut

| Phase | Description | Statut |
| --- | --- | --- |
| 1 | Fondations (auth, onboarding, layout, composants RP*) | ✅ Terminée |
| 2 | Transport — QR code + paiement Stripe Connect | ✅ Terminée |
| 3 | Location autonome — TTLock + Shelly + caution Hold | ⏳ À venir |
| 4 | Carte temps réel Mapbox | ⏳ À venir |
| 5 | Admin + push + tests E2E | ⏳ À venir |

## Phase 2 — livrables

- Migration Supabase Storage (`0002_storage.sql`) : buckets `avatars`, `provider-docs`, `asset-photos`, `booking-photos` + policies par utilisateur.
- Provider Setup (`/setup`) en 3 étapes : type de service, photo véhicule + pièces (Storage), Stripe Connect Express.
- Espace prestataire `(provider)` avec bottom nav dédié : `/dashboard` (revenus du jour, état Stripe), `/my-qr` (QR signé persistant), `/validate` (saisie code 4 chiffres OTP-style), `/earnings` (historique).
- Liste prestataires côté client (`/transport`) + fiche détail (`/transport/[id]`) avec checkout Stripe Elements (Apple Pay + Google Pay + carte) et révélation du code à 4 chiffres après confirmation.
- Scanner QR (`/transport/scan`) qui décode le JWT et redirige vers la fiche.
- API routes : `/api/stripe/connect/onboard` (compte Express + onboarding link), `/api/stripe/create-payment` (PaymentIntent + commission Stripe Connect), `/api/stripe/webhook` (succeeded/failed/account.updated → MAJ status + verified), `/api/transactions/validate` (provider entre le code 4 digits → completed), `/api/qr/resolve` (vérification JWT et résolution provider/access).
- `/wallet` côté client : total dépensé + historique paginé.
- Commission par verticale (5–10 %) appliquée via `application_fee_amount` Stripe Connect.

## Phase 1 — livrables

- Initialisation Next.js 14 + TypeScript strict + Tailwind.
- Thème dark luxury (palette stricte, fonts Playfair Display / Inter / JetBrains Mono).
- Schéma Supabase complet (`supabase/migrations/0001_init.sql`) avec RLS et Realtime.
- Composants UI ROUTEPASS réutilisables (`src/components/ui/`) :
  `RPButton`, `RPBadge`/`RPStatusBadge`, `RPStatusDot`, `RPInput`, `RPCard`,
  `RPBottomSheet`, `RPAvatar`, `RPQRDisplay`, `RPQRScanner`, `RPSkeleton`,
  `RPCardSkeleton`, `RPEmptyState`, `RPLogo`.
- Auth Supabase email + OTP téléphone, callback magic link.
- Onboarding 3 slides + sélection de rôle (`client` / `provider` / `owner`).
- Layout app avec navigation bottom 5 sections + swipe horizontal.
- Pages placeholders : `/home`, `/transport`, `/location`, `/map`, `/account`.
- Middleware d'authentification + redirections par rôle.

## Démarrage

```bash
npm install
cp .env.example .env.local   # remplir les clés Supabase, Stripe, etc.
npm run dev
```

Puis appliquer la migration sur votre projet Supabase :

```bash
# avec la CLI Supabase
supabase db push

# ou exécuter manuellement supabase/migrations/0001_init.sql
```

## Variables d'environnement

Voir [`.env.example`](./.env.example) — Supabase, Stripe, TTLock, Shelly, Mapbox, JWT QR secret, cron secret.

## Arborescence

```
src/
├── app/
│   ├── (auth)/         login, register, onboarding
│   ├── (app)/          home, transport, location, map, account
│   ├── auth/callback   magic-link Supabase
│   └── layout.tsx
├── components/
│   ├── layout/         BottomNav, SwipeContainer
│   └── ui/             RP* design system
├── lib/
│   ├── supabase/       client, server, types
│   └── utils.ts
└── middleware.ts
supabase/
└── migrations/0001_init.sql
```

## Règles de design

- Mobile-first sur tous les écrans.
- TypeScript strict — pas de `any`.
- Espacements multiples de 8px.
- Border radius : 20px cards / 12px boutons / 8px inputs.
- Skeleton loading sur toutes les listes.
- RLS Supabase activé partout.
- Stripe Connect uniquement — jamais stocker les fonds.
