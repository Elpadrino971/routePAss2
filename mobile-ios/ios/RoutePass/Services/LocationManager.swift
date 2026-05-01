import CoreLocation
import Observation

/// Gestionnaire de géolocalisation utilisateur.
/// Utilisé pour :
///   - filtrer prestataires / biens proches
///   - centrer la carte (`MapTrackingView`)
///   - envoyer la position du prestataire en course
///
/// L'app demande explicitement l'autorisation (NSLocationWhenInUseUsageDescription
/// dans Info.plist) lors du premier `requestAuthorization()`.
@Observable
final class LocationManager: NSObject {
    static let shared = LocationManager()

    private let manager = CLLocationManager()
    private(set) var lastLocation: CLLocation?
    private(set) var status: CLAuthorizationStatus = .notDetermined
    private(set) var lastError: String?

    var coordinate: CLLocationCoordinate2D? {
        lastLocation?.coordinate
    }

    /// Renvoie true si l'utilisateur a accordé l'accès à la position.
    var isAuthorized: Bool {
        status == .authorizedWhenInUse || status == .authorizedAlways
    }

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 25 // mètres
        status = manager.authorizationStatus
    }

    /// Demande l'autorisation et démarre les mises à jour si accordée.
    func requestAuthorization() {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()
        default:
            break
        }
    }

    /// Démarre les mises à jour de localisation continues.
    func startUpdating() {
        manager.startUpdatingLocation()
    }

    /// Arrête les mises à jour pour économiser la batterie.
    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    /// Récupère une position one-shot (utile pour une requête API immédiate).
    func requestOneShot() {
        manager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
        if isAuthorized {
            startUpdating()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        lastLocation = last
        lastError = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastError = error.localizedDescription
    }
}
