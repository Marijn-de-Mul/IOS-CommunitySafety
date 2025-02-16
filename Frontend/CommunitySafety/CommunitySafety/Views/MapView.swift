import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.441643, longitude: 5.469722),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .onAppear {
                if let location = locationManager.location {
                    updateRegion(location)
                }
            }
            .onChange(of: locationManager.location) { newLocation in
                if let location = newLocation {
                    updateRegion(location)
                }
            }
    }

    private func updateRegion(_ location: CLLocation) {
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
}
