import Foundation

struct User: Codable {
    let id: Int
    let username: String
    let longitude: Double
    let latitude: Double
}

struct Alert: Decodable, Identifiable {
    let id: Int
    let severity: Int
    let latitude: Double
    let longitude: Double
    let title: String
    let description: String
}

struct AlertsResponse: Decodable {
    let alerts: [Alert]
}

struct CheckTokenResponse: Codable {
    let message: String
    let user: User
}
