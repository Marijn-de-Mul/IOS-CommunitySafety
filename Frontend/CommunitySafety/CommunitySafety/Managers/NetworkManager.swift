import Foundation
import CoreLocation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://backend.cs.marijndemul.nl"
    private let tokenKey = "loginToken"
    private var sentAlerts: Set<String> = []

    private init() {}

    func login(username: String, password: String, completion: @escaping (Result<(User, String), Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/login") else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = json["access_token"] as? String {
                    let user = User(id: UUID().uuidString, username: username)
                    KeychainHelper.shared.saveToken(token, forKey: tokenKey)
                    completion(.success((user, token)))
                } else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func register(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        LocationManager.shared.getLocation { location in
            guard let url = URL(string: "\(self.baseURL)/register") else {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "username": username,
                "password": password,
                "latitude": location?.coordinate.latitude ?? NSNull(),
                "longitude": location?.coordinate.longitude ?? NSNull()
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Registration failed"])))
                    return
                }

                completion(.success("Registration successful. You can now login."))
            }
            task.resume()
        }
    }

    func updateLocation(location: CLLocation) {
        guard let url = URL(string: "\(baseURL)/update_location") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = getToken() else {
            print("No token available")
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to update location: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Failed to update location: No response")
                return
            }

            if httpResponse.statusCode == 200 {
                print("Location updated successfully")
            } else {
                print("Failed to update location: HTTP status code \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }

    func getToken() -> String? {
        return KeychainHelper.shared.getToken(forKey: tokenKey)
    }

    func createAlert(severity: String, title: String?, description: String?, completion: @escaping (Result<String, Error>) -> Void) {
        LocationManager.shared.getLocation { location in
            guard let location = location else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get location"])))
                return
            }

            guard let url = URL(string: "\(self.baseURL)/alerts") else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            let alertIdentifier = "\(severity)-\(title ?? "")-\(description ?? "")"

            // Check if the alert has already been sent
            guard !self.sentAlerts.contains(alertIdentifier) else {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "This alert has already been sent."])))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.getToken() ?? "")", forHTTPHeaderField: "Authorization")

            let body: [String: Any] = [
                "severity": severity,
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "title": title ?? "",
                "description": description ?? ""
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                completion(.failure(error))
                return
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create alert"])))
                    return
                }

                // Add the alert identifier to the set after successful request
                self.sentAlerts.insert(alertIdentifier)
                completion(.success("Alert created successfully"))
            }

            task.resume()
        }
    }
    
    func getAlerts(completion: @escaping (Result<[Alert], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/alerts") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let alertsResponse = try JSONDecoder().decode(AlertsResponse.self, from: data)
                completion(.success(alertsResponse.alerts))
            } catch {
                let customError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode JSON", "rawData": data])
                completion(.failure(customError))
            }
        }
        
        task.resume()
    }
    
    func deleteAlert(_ id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/alerts/\(id)") else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = getToken() else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No token available"])))
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to delete alert"])))
                return
            }
            
            completion(.success(()))
        }
        task.resume()
    }
}
