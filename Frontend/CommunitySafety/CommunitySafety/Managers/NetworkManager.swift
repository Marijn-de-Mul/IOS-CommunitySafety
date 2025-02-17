import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.yourservice.com"

    private init() {}

    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Mock login API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let mockUser = User(id: UUID().uuidString, username: username)
            completion(.success(mockUser))
        }
    }

    func register(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Mock register API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let mockUser = User(id: UUID().uuidString, username: username)
            completion(.success(mockUser))
        }
    }

    func sendAlert(severity: Int, title: String?, description: String?, completion: @escaping (Result<Alert, Error>) -> Void) {
        // Implement send alert API call
    }

    func fetchAlerts(latitude: Double, longitude: Double, radius: Double, completion: @escaping (Result<[Alert], Error>) -> Void) {
        // Implement fetch alerts API call
    }
}
