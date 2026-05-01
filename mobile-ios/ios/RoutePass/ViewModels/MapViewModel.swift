import SwiftUI
import MapKit
import CoreLocation

@Observable
final class MapViewModel {
    var mapItems: [MapItem] = []
    var selectedMapItem: MapItem?
    var showMarkerDetail: Bool = false
    var cameraPosition: MapCameraPosition = .automatic
    var isMapUnlocked: Bool = false
    var activeTransportProvider: Provider?
    var activeRentalBooking: RentalBooking?
    var providerTrackingCoordinate: CLLocationCoordinate2D?
    var trackingETA: String = ""
    var showRoute: Bool = false
    var routeCoordinates: [CLLocationCoordinate2D] = []

    private let dakarCenter = CLLocationCoordinate2D(latitude: 14.6937, longitude: -17.4441)

    func unlockMapForTransport(provider: Provider) {
        isMapUnlocked = true
        activeTransportProvider = provider

        let item = MapItem.fromProvider(provider)
        mapItems = [item]

        providerTrackingCoordinate = provider.coordinate

        cameraPosition = .region(MKCoordinateRegion(
            center: provider.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))

        simulateProviderMovement(from: provider.coordinate)
    }

    func unlockMapForRental(booking: RentalBooking) {
        isMapUnlocked = true
        activeRentalBooking = booking

        let item = MapItem.fromRental(booking.item)
        mapItems = [item]

        cameraPosition = .region(MKCoordinateRegion(
            center: booking.item.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    func loadAllItems(providers: [Provider], rentals: [RentalItem]) {
        var items: [MapItem] = []
        items.append(contentsOf: providers.map { MapItem.fromProvider($0) })
        items.append(contentsOf: rentals.map { MapItem.fromRental($0) })
        mapItems = items

        cameraPosition = .region(MKCoordinateRegion(
            center: dakarCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        ))
    }

    func selectItem(_ item: MapItem) {
        selectedMapItem = item
        showMarkerDetail = true

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            cameraPosition = .region(MKCoordinateRegion(
                center: item.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            ))
        }
    }

    func dismissDetail() {
        showMarkerDetail = false
        selectedMapItem = nil
    }

    func resetMap() {
        isMapUnlocked = false
        activeTransportProvider = nil
        activeRentalBooking = nil
        providerTrackingCoordinate = nil
        mapItems = []
        showRoute = false
        routeCoordinates = []
    }

    func openInAppleMaps(coordinate: CLLocationCoordinate2D, name: String) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    private func simulateProviderMovement(from start: CLLocationCoordinate2D) {
        let offsets: [(Double, Double)] = [
            (0.0005, -0.0003),
            (0.001, -0.0005),
            (0.0015, -0.0002),
            (0.002, 0.0001),
            (0.0025, 0.0004),
        ]

        for (index, offset) in offsets.enumerated() {
            Task {
                try? await Task.sleep(for: .seconds(Double(index + 1) * 3))
                let newCoord = CLLocationCoordinate2D(
                    latitude: start.latitude + offset.0,
                    longitude: start.longitude + offset.1
                )
                providerTrackingCoordinate = newCoord
                let remaining = max(1, 5 - index)
                trackingETA = "\(remaining) min"

                if let first = mapItems.first, first.isTransportActive {
                    mapItems[0] = MapItem(
                        id: first.id,
                        name: first.name,
                        subtitle: first.subtitle,
                        category: first.category,
                        status: first.status,
                        coordinate: newCoord,
                        address: first.address,
                        ownerName: first.ownerName,
                        ownerVerified: first.ownerVerified,
                        price: first.price,
                        rating: first.rating,
                        icon: first.icon,
                        isTransportActive: true,
                        eta: "\(remaining) min",
                        endDate: nil
                    )
                }
            }
        }
    }
}
