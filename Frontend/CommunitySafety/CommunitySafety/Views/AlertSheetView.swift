import SwiftUI

struct AlertSheetView: View {
    @Binding var showSheet: Bool
    @Binding var showCustomAlert: Bool
    @Binding var selectedAlert: String?
    @Binding var alerts: [Alert]
    @ObservedObject var locationManager = LocationManager.shared

    let alertTypes = [
        ("flame", "Fire", 10),
        ("flame", "Gas Leak", 9),
        ("car", "Car Accident", 8),
        ("house", "Burglary", 7),
        ("person.fill", "Suspicious Person", 5),
        ("bell", "Noise Complaint", 3),
        ("leaf", "Tree Down", 4),
        ("cloud.rain", "Flood", 6),
        ("wind", "Strong Winds", 4),
        ("snow", "Snowstorm", 6),
        ("thermometer.snowflake", "Cold Weather", 3),
        ("thermometer.sun", "Heatwave", 6),
        ("bolt", "Power Outage", 5),
        ("drop", "Water Leak", 4),
        ("ant", "Pest Infestation", 3),
        ("pawprint", "Lost Pet", 2),
        ("bicycle", "Stolen Bike", 3),
        ("trash", "Littering", 2),
        ("exclamationmark.triangle", "Hazard", 7),
        ("shield", "Vandalism", 4),
        ("heart", "Medical Emergency", 10),
        ("phone", "Phone Scam", 2),
        ("envelope", "Mail Theft", 2),
        ("wifi", "Internet Outage", 3),
        ("lock", "Lockout", 2),
        ("key", "Lost Key", 2),
        ("cart", "Shoplifting", 3),
        ("bus", "Public Transport Issue", 3),
        ("building.2", "Building Collapse", 9),
        ("globe", "Environmental Issue", 5)
    ]

    var body: some View {
        NavigationView {
            TabView {
                ForEach(0..<5) { index in
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(0..<6) { i in
                            let alertIndex = index * 6 + i
                            let alert = alertTypes[alertIndex]
                            VStack {
                                Button(action: {
                                    handleAlertSelection(alert: alert)
                                }) {
                                    VStack {
                                        Image(systemName: alert.0)
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.white)
                                        Text(alert.1)
                                            .foregroundColor(.white)
                                            .padding(.top, 5)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .navigationBarTitle("Send Alert", displayMode: .inline)
            .colorScheme(.dark)
        }
        .colorScheme(.dark)
    }

    private func handleAlertSelection(alert: (String, String, Int)) {
        selectedAlert = alert.1
        showCustomAlert = true
        showSheet = false
        if let location = locationManager.location {
            let description = "Type: \(alert.1), Severity: \(alert.2)"
            let newAlert = Alert(id: UUID().hashValue, severity: alert.2, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, title: alert.1, description: description)
            alerts.append(newAlert)
            NetworkManager.shared.createAlert(severity: "\(alert.2)", title: alert.1, description: description) { result in
                switch result {
                case .success(let message):
                    print(message)
                case .failure(let error):
                    print("Error creating alert: \(error.localizedDescription)")
                }
            }
        }
    }
}
