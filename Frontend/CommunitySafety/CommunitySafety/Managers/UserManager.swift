import Foundation
import CoreLocation

class UserManager {
    static let shared = UserManager()
    private var currentUser: User?
    private let locationManager = CLLocationManager()

    private init() {}

    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        NetworkManager.shared.login(username: username, password: password) { result in
            switch result {
            case .success(let user):
                self.currentUser = user
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func register(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        locationManager.requestWhenInUseAuthorization()
        guard let location = locationManager.location else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Location not available"])))
            return
        }
        
        let locationString = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        NetworkManager.shared.register(username: username, password: password, location: locationString) { result in
            switch result {
            case .success(let user):
                self.currentUser = user
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getCurrentUser() -> User? {
        return currentUser
    }
}