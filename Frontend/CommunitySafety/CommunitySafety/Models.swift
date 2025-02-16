import Foundation

struct User: Codable {
    let id: String
    let username: String
}

struct Alert: Identifiable {
    let id: Int
    let latitude: Double
    let longitude: Double
    let severity: Int
    let title: String
    let description: String
}
