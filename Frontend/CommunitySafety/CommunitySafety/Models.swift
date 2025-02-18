import Foundation

struct User: Codable {
    let id: String
    let username: String
}

struct Alert: Decodable, Identifiable {
    let id: Int
    let severity: Int
    let latitude: Double
    let longitude: Double
    let title: String
    let description: String
}
