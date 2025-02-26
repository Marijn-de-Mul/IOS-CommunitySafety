import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }

    func getLocation(completion: @escaping (CLLocation?) -> Void) {
        if let location = location {
            completion(location)
        } else {
            locationManager.requestLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                completion(self.location)
            }
        }
    }
}
