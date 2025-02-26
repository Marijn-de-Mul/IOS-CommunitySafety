import Foundation
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager()
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    private init() {}
    
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        NetworkManager.shared.login(username: username, password: password) { result in
            switch result {
            case .success(let (user, _)):
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isLoggedIn = true
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
            self.isLoggedIn = false
        }
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func checkTokenValidity() {
        NetworkManager.shared.checkToken { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isLoggedIn = true
                }
            case .failure(let error):
                if (error as NSError).code == 401 {
                    DispatchQueue.main.async {
                        self.isLoggedIn = false
                        self.currentUser = nil
                    }
                } else {
                    print("Error checking token validity: \(error.localizedDescription)")
                }
            }
        }
    }
}
