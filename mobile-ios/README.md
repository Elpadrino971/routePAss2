# ROUTEPASS — App iOS native (SwiftUI)

App native iOS générée par [Rork](https://rork.com), refondue en **dark luxury strict** et branchée sur le back Next.js / Supabase / Stripe du repo.

Bundle id : **`app.routepass.mobile`**.

## Statut des phases mobile

| Phase | Description | Statut |
| --- | --- | --- |
| M1 | Alignement design (theme dark luxury, onboarding hero, 7 onglets, géoloc) | ✅ Terminée |
| M2 | Auth Supabase (`supabase-swift`, OTP email/SMS, Keychain) | ⏳ À venir |
| M3 | Transport + Stripe (PaymentSheet, Apple Pay, code 4 chiffres) | ⏳ À venir |
| M4 | Location + IoT (Hold, TTLock checkin/checkout) | ⏳ À venir |
| M5 | Carte temps réel Mapbox (positions GPS live via Realtime) | ⏳ À venir |
| M6 | Wallet + Admin + Push APNs | ⏳ À venir |

## Phase M1 — livrables

- **`RPTheme`** entièrement refondu : palette dark luxury exacte (`#08080D`, `#0F0F18`, gold `#C9A84C` / `#E8C96A`), `goldGradient`, alias compatibilité (`accent`, `backgroundPrimary`, etc.).
- **`RPFont`** typographies (Playfair Display si embarquée, sinon `serif` système ; Inter ; JetBrains Mono).
- **Boutons** : `RPPrimaryButtonStyle` (dégradé or + ombre), Secondary (bordure or), Ghost, Destructive — avec sizes `sm/md/lg`.
- **`OnboardingView`** refait pour matcher pixel-près les mockups iPhone 16 fournis :
  - 3 slides hero plein écran (Unsplash) avec titre serif, accent or italique (« Payez, montez, **partez** »), divider « R » or au centre, dots dorés, bouton « Suivant » or en bas.
- **`ContentView`** : 7 onglets (Accueil, Transport, Location, Outils, Immobilier, **Carte**, Compte) avec dock or signature flottant et haptic feedback.
- **`MapTabView`** : nouvelle vue carte plein écran (MapKit pour M1, Mapbox en M5) avec géolocalisation utilisateur en background, pin user et marqueurs or, sheet « À proximité » bottom-anchored avec scroll horizontal.
- **`LocationManager`** (`@Observable`) : singleton CoreLocation, demande d'autorisation, mises à jour live, accessor `coordinate`.
- **`Config`** : lecteur de configuration depuis `Info.plist` pour `RP_API_BASE_URL`, `RP_SUPABASE_URL`, `RP_SUPABASE_ANON_KEY`, `RP_STRIPE_PUBLISHABLE_KEY`, `RP_MAPBOX_TOKEN`, `RP_APPLE_PAY_MERCHANT_ID`.
- **`Config.xcconfig`** : fichier de configuration externe à associer aux build settings Xcode.
- **Bundle id** changé de `app.rork.dhewco7druid4iyg4ixk8` → `app.routepass.mobile` (+ `.tests` et `.uitests`).
- **Permission caméra** ajoutée (`NSCameraUsageDescription`) pour le scanner QR.
- **Permission localisation** déjà présente.

## Démarrage local

```bash
cd mobile-ios/ios
open RoutePass.xcodeproj
```

Puis dans Xcode :

1. **Project → Info → Configurations** → choisir `Config` (xcconfig) comme base pour Debug et Release sur la cible `RoutePass`.
2. Dupliquer `Config.xcconfig` en `Config.local.xcconfig` (déjà gitignore'é) et y mettre vos vraies clés Supabase / Stripe / Mapbox.
3. `Cmd + R` pour lancer dans le simulateur iPhone 16.

## Architecture

```
ios/RoutePass/
├── RoutePassApp.swift          // Point d'entrée
├── ContentView.swift           // 7 onglets + dock
├── Config.xcconfig             // Configuration externe
├── Models/                     // Modèles + mock data
├── Services/
│   ├── LocationManager.swift   // CoreLocation
│   └── LocationService.swift   // (Rork)
├── Utilities/
│   ├── RPTheme.swift           // Dark luxury strict
│   ├── RPButtonStyle.swift     // 4 styles boutons
│   └── Config.swift            // Lecture Info.plist
├── ViewModels/                 // MVVM par domaine
└── Views/
    ├── Auth/                   // Splash, Onboarding, OTP, Role
    ├── Components/             // RPCard, RPBadge, RPTextField...
    ├── Sections/               // 7 onglets : Accueil, Transport, Location...
    ├── Map/                    // MapTabView (M1) + MapTracking (M5)
    ├── Transport/              // QRScanner, Payment*, Provider
    ├── Location/               // Booking, Rental, AutonomousAccess
    ├── Tools/                  // Tool*
    ├── Wallet/                 // Wallet, Withdraw, Revenue
    └── Admin/                  // Dashboard, Validation, Payout
```

## Liens

- **Back Next.js** : branche `claude/build-routepass-payment-4bNBR` du même repo (web + API + Supabase + Stripe + IoT).
- **Source Rork** : https://github.com/Elpadrino971/rork-routepass
