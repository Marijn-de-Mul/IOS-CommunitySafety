import Foundation
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager()
    @Published var currentUser: User?

    private init() {}

    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        NetworkManager.shared.login(username: username, password: password) { result in
            switch result {
            case .success(let (user, _)):
                DispatchQueue.main.async {
                    self.currentUser = user
                }
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func register(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) { 
        NetworkManager.shared.register(username: username, password: password) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout() {
        DispatchQueue.main.async {
            self.currentUser = nil
        }
    }

    func getCurrentUser() -> User? {
        return currentUser
    }
}
