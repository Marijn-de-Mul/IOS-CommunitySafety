import Foundation

struct User: Codable {
    let id: String
    let username: String
}

struct Alert: Codable {
    let id: String
    let severity: Int
    let title: String?
    let description: String?
    let latitude: Double
    let longitude: Double
    let timestamp: Date
}
