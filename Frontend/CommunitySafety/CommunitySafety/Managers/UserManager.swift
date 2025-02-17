import Foundation

class UserManager {
    static let shared = UserManager()
    private var currentUser: User?

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
        NetworkManager.shared.register(username: username, password: password) { result in
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
