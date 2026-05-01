# RoutePass — Design System & Swipe Navigation Foundation

## What We're Building

The foundation layer of **RoutePass** — a premium service app with Apple-quality design. This step covers only the design system and horizontal swipe navigation. No business logic yet.

---

### **Features**

- Swipe horizontally between 5 sections: Accueil, Transport, Location, Immobilier, Mon Compte
- Minimalist dot indicator at the bottom showing the current section
- Fluid spring animations on every page transition
- Reusable card component with image, title, status badge, and price
- Reusable status badges (Disponible, Occupé, Nettoyage, Libre le...)
- Reusable button styles (primary gold, secondary outline, ghost)
- Skeleton shimmer loading effect on all lists
- Haptic feedback on taps and confirmations
- Mock data throughout — no real backend

---

### **Design**

- **Theme**: White background in light mode, near-black (#0A0A0A) in dark mode
- **Accent color**: Matte gold (#D4A843) for primary actions and highlights
- **Typography**: SF Pro Display (bold titles), SF Pro Rounded (friendly labels/badges)
- **Cards**: Large corner radius (20pt), subtle diffuse shadow, spring scale-in animation on appear
- **Badges**: Capsule-shaped, color-coded — green (Disponible), red (Occupé), orange (Nettoyage), blue (Libre le...)
- **Buttons**: Gold filled (primary), outline with gold border (secondary), text-only (ghost) — all with 14pt corner radius
- **Spacing**: Strict 8pt grid system throughout
- **Animations**: Spring appear on cards (scale 0.95→1 + fade), smooth swipe transitions, shimmer loading skeletons
- **Haptics**: Light tap on interactions, medium on confirmations

---

### **Screens**

1. **Main View** — Full-screen horizontal pager with 5 sections, swipe to navigate, dot indicator at bottom
2. **Accueil (Home)** — Welcome header with greeting, horizontal scroll of featured cards, vertical list of recent items with skeleton loading
3. **Transport** — Section header + list of transport service cards with status badges and pricing
4. **Location** — Section header + grid of rental cards with availability badges
5. **Immobilier** — Section header + list of property cards with status and price
6. **Mon Compte** — Profile avatar area, account options list, settings section

Each section shows mock data with the reusable design components (RPCard, RPBadge, RPButton).

---

### **App Icon**

- Matte gold "R" monogram on a deep black background, clean and luxurious, minimal style inspired by premium brand logos

