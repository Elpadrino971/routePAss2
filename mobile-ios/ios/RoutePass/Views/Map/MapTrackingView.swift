import SwiftUI
import MapKit

struct MapTrackingView: View {
    @State private var mapViewModel = MapViewModel()
    @State private var locationService = LocationService()
    @State private var hapticTrigger: Int = 0

    let mapItems: [MapItem]
    let isPaymentConfirmed: Bool
    let activeProvider: Provider?
    let activeBooking: RentalBooking?
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                mapContent

                if let provider = activeProvider, mapViewModel.isMapUnlocked {
                    trackingOverlay(provider: provider)
                }
            }
            .navigationTitle(isPaymentConfirmed ? "Suivi en direct" : "Carte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { onDismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            mapViewModel.cameraPosition = .userLocation(fallback: .automatic)
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(RPTheme.accent)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $mapViewModel.showMarkerDetail) {
                if let item = mapViewModel.selectedMapItem {
                    MarkerDetailSheet(
                        item: item,
                        isPaymentConfirmed: isPaymentConfirmed,
                        onRoute: {
                            mapViewModel.openInAppleMaps(
                                coordinate: item.coordinate,
                                name: item.name
                            )
                        },
                        onContact: {
                            mapViewModel.dismissDetail()
                        },
                        onDismiss: {
                            mapViewModel.dismissDetail()
                        }
                    )
                }
            }
            .onAppear {
                locationService.requestPermission()
                setupMap()
            }
            .onDisappear {
                locationService.stopTracking()
            }
            .sensoryFeedback(.selection, trigger: hapticTrigger)
        }
    }

    private var mapContent: some View {
        Map(position: $mapViewModel.cameraPosition) {
            UserAnnotation()

            ForEach(mapViewModel.mapItems) { item in
                Annotation(item.name, coordinate: item.coordinate) {
                    Button {
                        mapViewModel.selectItem(item)
                        hapticTrigger += 1
                    } label: {
                        MapMarkerView(
                            item: item,
                            isSelected: mapViewModel.selectedMapItem?.id == item.id
                        )
                    }
                }
            }

            if let tracking = mapViewModel.providerTrackingCoordinate,
               let userLoc = locationService.location?.coordinate {
                MapPolyline(coordinates: [tracking, userLoc])
                    .stroke(RPTheme.accent, style: StrokeStyle(lineWidth: 3, dash: [8, 6]))
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
    }

    private func trackingOverlay(provider: Provider) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: RPTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(MapItemCategory.taxi.markerColor.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: "car.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(MapItemCategory.taxi.markerColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.name)
                        .font(.system(.subheadline, design: .default, weight: .bold))
                        .foregroundStyle(RPTheme.textPrimary)

                    if !mapViewModel.trackingETA.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                            Text("Arrive dans \(mapViewModel.trackingETA)")
                                .font(.system(.caption, design: .default, weight: .medium))
                                .foregroundStyle(.green)
                                .contentTransition(.numericText())
                        }
                    } else {
                        Text(provider.vehicleType)
                            .font(.system(.caption, design: .default))
                            .foregroundStyle(RPTheme.textSecondary)
                    }
                }

                Spacer(minLength: 0)

                RPBadge(status: .disponible)
            }
            .padding(RPTheme.Spacing.md)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
            .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.bottom, RPTheme.Spacing.md)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func setupMap() {
        if let provider = activeProvider, isPaymentConfirmed {
            mapViewModel.unlockMapForTransport(provider: provider)
        } else if let booking = activeBooking, isPaymentConfirmed {
            mapViewModel.unlockMapForRental(booking: booking)
        } else {
            mapViewModel.loadAllItems(
                providers: TransportMockData.providers,
                rentals: LocationMockData.rentalItems
            )
        }
    }
}
