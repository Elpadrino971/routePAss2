import SwiftUI
import MapKit

/// Onglet "Carte" — vue plein écran avec géolocalisation utilisateur en
/// background et liste filtrable des prestataires + biens proches.
///
/// En Phase M5, cette vue sera remplacée par Mapbox GL et branchée sur les
/// channels Realtime Supabase pour la position GPS live des prestataires.
/// Pour Phase M1 on utilise MapKit + données mockées.
struct MapTabView: View {
    @State private var locationManager = LocationManager.shared
    @State private var camera: MapCameraPosition = .userLocation(fallback: .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        )
    ))

    @State private var sheetExpanded: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $camera) {
                UserAnnotation()

                ForEach(MockMapMarkers.all) { m in
                    Annotation(m.title, coordinate: m.coordinate) {
                        MapMarkerView(item: m)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControlVisibility(.hidden)
            .ignoresSafeArea()

            header
            permissionPromptIfNeeded
        }
        .preferredColorScheme(.dark)
        .onAppear {
            locationManager.requestAuthorization()
        }
        .sheet(isPresented: .constant(true)) {
            nearbySheet
                .presentationDetents([.height(120), .medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationDragIndicator(.visible)
                .presentationBackground(RPTheme.dark)
                .interactiveDismissDisabled()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("CARTE").rpKicker()
                Text("À proximité")
                    .font(RPFont.display(22))
                    .foregroundStyle(RPTheme.white)
            }
            Spacer()
            recentLocationButton
        }
        .padding(.horizontal, RPTheme.Spacing.lg)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(
            LinearGradient(
                colors: [RPTheme.black.opacity(0.85), RPTheme.black.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }

    private var recentLocationButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if let coord = locationManager.coordinate {
                    camera = .region(
                        MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                        )
                    )
                } else {
                    camera = .userLocation(fallback: camera)
                }
            }
        } label: {
            Image(systemName: "location.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(RPTheme.gold)
                .padding(10)
                .background(
                    Circle()
                        .fill(RPTheme.dark)
                        .overlay(Circle().stroke(RPTheme.gold.opacity(0.3), lineWidth: 1))
                )
        }
    }

    @ViewBuilder
    private var permissionPromptIfNeeded: some View {
        if locationManager.status == .denied {
            VStack(alignment: .leading, spacing: 6) {
                Text("Autorisation refusée")
                    .font(RPFont.body(13, weight: .semibold))
                    .foregroundStyle(RPTheme.white)
                Text("Activez la localisation dans Réglages pour voir les services autour de vous.")
                    .font(RPFont.body(12))
                    .foregroundStyle(RPTheme.gray)
            }
            .padding(12)
            .background(RPTheme.dark)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(RPTheme.warning.opacity(0.4)))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, RPTheme.Spacing.lg)
            .padding(.top, 80)
        }
    }

    // MARK: - Bottom sheet

    private var nearbySheet: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("À PROXIMITÉ").rpKicker()
            Text("\(MockMapMarkers.all.count) résultats")
                .font(RPFont.display(18))
                .foregroundStyle(RPTheme.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MockMapMarkers.all) { m in
                        nearbyCard(m)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(RPTheme.Spacing.lg)
        .padding(.bottom, 40)
    }

    private func nearbyCard(_ m: MockMapMarker) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: m.icon)
                    .foregroundStyle(RPTheme.gold)
                Spacer()
                Circle()
                    .fill(RPTheme.success)
                    .frame(width: 8, height: 8)
            }
            Text(m.title)
                .font(RPFont.body(14, weight: .semibold))
                .foregroundStyle(RPTheme.white)
            Text(m.subtitle)
                .font(RPFont.body(11))
                .foregroundStyle(RPTheme.gray)
                .lineLimit(1)
        }
        .padding(12)
        .frame(width: 200, alignment: .leading)
        .background(RPTheme.dark2)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(RPTheme.border))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Mock data (sera remplacé par Supabase realtime en Phase M5)

struct MockMapMarker: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let coordinate: CLLocationCoordinate2D
    let tone: Color
}

enum MockMapMarkers {
    static let all: [MockMapMarker] = [
        .init(title: "Mercedes Classe E", subtitle: "Taxi · 1.2 km",   icon: "car.fill",        coordinate: .init(latitude: 48.860, longitude: 2.345), tone: RPTheme.gold),
        .init(title: "Loft Marais",        subtitle: "Bien · 0.8 km",   icon: "building.2.fill", coordinate: .init(latitude: 48.857, longitude: 2.362), tone: RPTheme.gold),
        .init(title: "Sunseeker 42",       subtitle: "Bateau · 4.5 km", icon: "ferry.fill",      coordinate: .init(latitude: 48.852, longitude: 2.355), tone: RPTheme.info),
        .init(title: "Studio Rivoli",      subtitle: "Bien · 1.6 km",   icon: "key.fill",        coordinate: .init(latitude: 48.862, longitude: 2.350), tone: RPTheme.gold),
    ]
}

private struct MapMarkerView: View {
    let item: MockMapMarker

    var body: some View {
        Image(systemName: item.icon)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(RPTheme.black)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(RPTheme.goldGradient)
                    .overlay(Circle().stroke(RPTheme.black.opacity(0.4), lineWidth: 1))
            )
            .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
    }
}
