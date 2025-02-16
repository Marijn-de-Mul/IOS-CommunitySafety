import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    private var updateTimer: Timer?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startLocationUpdateTimer()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        if let location = location {
            NetworkManager.shared.updateLocation(location: "\(location.coordinate.latitude),\(location.coordinate.longitude)") { result in
                switch result {
                case .success:
                    print("Location updated successfully")
                case .failure(let error):
                    print("Failed to update location: \(error)")
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    private func startLocationUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateLocationToServer()
        }
    }

    private func updateLocationToServer() {
        guard let location = location else { return }
        NetworkManager.shared.updateLocation(location: "\(location.coordinate.latitude),\(location.coordinate.longitude)") { result in
            switch result {
            case .success:
                print("Location updated successfully")
            case .failure(let error):
                print("Failed to update location: \(error)")
            }
        }
    }

    deinit {
        updateTimer?.invalidate()
    }
}