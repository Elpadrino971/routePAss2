import Foundation

/// Lecteur de configuration ROUTEPASS.
/// Les clés sont lues depuis Info.plist (defines via xcconfig ou Build Settings User-Defined).
/// En l'absence de la clé, on utilise des valeurs par défaut adaptées au dev/sandbox.
///
/// Renommé `AppConfig` (au lieu de `Config`) car le `.gitignore` hérité de
/// Rork exclut tout fichier nommé `Config.swift`.
enum AppConfig {
    /// URL du back-end Next.js (API routes Stripe / bookings / cron / push).
    static var apiBaseURL: URL {
        URL(string: string("RP_API_BASE_URL") ?? "https://routepass.vercel.app")!
    }

    /// Supabase
    static var supabaseURL: URL {
        URL(string: string("RP_SUPABASE_URL") ?? "https://example.supabase.co")!
    }
    static var supabaseAnonKey: String {
        string("RP_SUPABASE_ANON_KEY") ?? ""
    }

    /// Stripe (publishable key, jamais le secret côté mobile)
    static var stripePublishableKey: String {
        string("RP_STRIPE_PUBLISHABLE_KEY") ?? ""
    }

    /// Mapbox public token (commence par "pk.")
    static var mapboxToken: String {
        string("RP_MAPBOX_TOKEN") ?? ""
    }

    /// Apple Pay merchant id (configuré dans les Capabilities Xcode)
    static var applePayMerchantId: String {
        string("RP_APPLE_PAY_MERCHANT_ID") ?? "merchant.app.routepass.mobile"
    }

    /// Bundle id de l'app (utilisé pour les deep links et les notifications).
    static var bundleId: String {
        Bundle.main.bundleIdentifier ?? "app.routepass.mobile"
    }

    // MARK: - Helpers

    private static func string(_ key: String) -> String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
