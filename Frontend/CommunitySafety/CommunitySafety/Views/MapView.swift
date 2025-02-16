import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.441643, longitude: 5.469722),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @StateObject private var locationManager = LocationManager()
    @State private var alerts: [Alert] = []
    @State private var updateTimer: Timer?

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: alerts) { alert in
            MapPin(coordinate: CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude), tint: .red)
        }
        .onAppear {
            if let location = locationManager.location {
                updateRegion(location)
                fetchAlerts()
                startUpdateTimer()
            }
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                updateRegion(location)
                fetchAlerts()
            }
        }
    }

    private func updateRegion(_ location: CLLocation) {
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }

    private func fetchAlerts() {
        guard let location = locationManager.location else { return }
        NetworkManager.shared.fetchAlerts(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, radius: 10.0) { result in
            switch result {
            case .success(let alerts):
                self.alerts = alerts
            case .failure(let error):
                print("Failed to fetch alerts: \(error)")
            }
        }
    }

    private func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.fetchAlerts()
        }
    }

    deinit {
        updateTimer?.invalidate()
    }
}
