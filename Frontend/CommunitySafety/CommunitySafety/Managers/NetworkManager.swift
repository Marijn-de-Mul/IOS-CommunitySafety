import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://backend.cs.marijndemul.nl"
    private var token: String?

    private init() {}

    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let token = json?["access_token"] as? String {
                    self.token = token
                    let mockUser = User(id: UUID().uuidString, username: username)
                    completion(.success(mockUser))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func register(username: String, password: String, location: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["username": username, "password": password, "location": location]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let _ = json?["id"] as? String {
                    let mockUser = User(id: UUID().uuidString, username: username)
                    completion(.success(mockUser))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func sendAlert(severity: Int, title: String?, description: String?, completion: @escaping (Result<Alert, Error>) -> Void) {
        guard let token = token else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        let url = URL(string: "\(baseURL)/alerts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["severity": severity, "title": title ?? "", "description": description ?? ""]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let id = json?["id"] as? Int {
                    let alert = Alert(id: id, severity: severity, title: title, description: description)
                    completion(.success(alert))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid input"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchAlerts(latitude: Double, longitude: Double, radius: Double, completion: @escaping (Result<[Alert], Error>) -> Void) {
        guard let token = token else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        let url = URL(string: "\(baseURL)/alerts?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                let alerts = json?.compactMap { dict -> Alert? in
                    guard let id = dict["id"] as? Int,
                          let severity = dict["severity"] as? Int,
                          let title = dict["title"] as? String,
                          let description = dict["description"] as? String else {
                        return nil
                    }
                    return Alert(id: id, severity: severity, title: title, description: description)
                }
                completion(.success(alerts ?? []))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func updateLocation(location: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = token else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])))
            return
        }
        
        let url = URL(string: "\(baseURL)/update_location")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["location": location]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
}