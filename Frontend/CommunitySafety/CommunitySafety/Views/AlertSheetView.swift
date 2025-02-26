import SwiftUI

struct AlertSheetView: View {
    @Binding var showSheet: Bool
    @Binding var showCustomAlert: Bool
    @Binding var selectedAlert: String?
    @Binding var alerts: [Alert]
    @ObservedObject var locationManager = LocationManager.shared

    let alertTypes = [
        ("flame", "Fire"),
        ("flame", "Gas Leak"),
        ("car", "Car Accident"),
        ("house", "Burglary"),
        ("person.fill", "Suspicious Person"),
        ("bell", "Noise Complaint"),
        ("leaf", "Tree Down"),
        ("cloud.rain", "Flood"),
        ("wind", "Strong Winds"),
        ("snow", "Snowstorm"),
        ("thermometer.snowflake", "Cold Weather"),
        ("thermometer.sun", "Heatwave"),
        ("bolt", "Power Outage"),
        ("drop", "Water Leak"),
        ("ant", "Pest Infestation"),
        ("pawprint", "Lost Pet"),
        ("bicycle", "Stolen Bike"),
        ("trash", "Littering"),
        ("exclamationmark.triangle", "Hazard"),
        ("shield", "Vandalism"),
        ("heart", "Medical Emergency"),
        ("phone", "Phone Scam"),
        ("envelope", "Mail Theft"),
        ("wifi", "Internet Outage"),
        ("lock", "Lockout"),
        ("key", "Lost Key"),
        ("cart", "Shoplifting"),
        ("bus", "Public Transport Issue"),
        ("building.2", "Building Collapse"),
        ("globe", "Environmental Issue")
    ]

    var body: some View {
        NavigationView {
            TabView {
                ForEach(0..<5) { index in
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(0..<6) { i in
                            let alert = alertTypes[index * 6 + i]
                            VStack {
                                Button(action: {
                                    selectedAlert = alert.1
                                    showCustomAlert = true
                                    showSheet = false
                                    if let location = locationManager.location {
                                        let newAlert = Alert(id: UUID().hashValue, severity: 1, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, title: alert.1, description: "")
                                        alerts.append(newAlert)
                                    }
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
        }
    }
}
