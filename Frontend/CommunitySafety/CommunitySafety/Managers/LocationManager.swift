import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private var locationCompletion: ((CLLocation?) -> Void)?
    private var updateTimer: Timer?

    private override init() {
        super.init()
        locationManager.delegate = self
        requestLocationPermission()
    }

    func requestLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                break
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
                startUpdatingLocationPeriodically()
            @unknown default:
                break
            }
        } else {
            // Handle location services disabled
        }
    }

    func getLocation(completion: @escaping (CLLocation?) -> Void) {
        locationCompletion = completion
        if let location = location {
            completion(location)
        } else {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        locationCompletion?(location)
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            startUpdatingLocationPeriodically()
        } else {
            location = nil
            stopUpdatingLocationPeriodically()
        }
    }

    private func startUpdatingLocationPeriodically() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.locationManager.startUpdatingLocation()
            if let location = self.location {
                NetworkManager.shared.updateLocation(location: location)
            }
        }
    }

    private func stopUpdatingLocationPeriodically() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
}
