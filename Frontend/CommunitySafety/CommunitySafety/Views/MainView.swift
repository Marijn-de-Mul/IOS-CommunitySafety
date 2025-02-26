import SwiftUI
import CoreLocation

struct MainView: View {
    @State private var isMenuOpen = false
    @State private var showAlert = false
    @State private var showSheet = false
    @State private var showCustomAlert = false
    @State private var selectedAlert: String?
    @State private var alerts: [Alert] = []
    @State private var showLoginAlert = false
    @ObservedObject private var userManager = UserManager.shared
    private let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            ZStack {
                MapView(alerts: $alerts)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    MenuButtonView(isMenuOpen: $isMenuOpen)
                    Spacer()
                }
                .padding(.top)

                VStack {
                    Spacer()
                    AlertButtonView(showSheet: $showSheet, showLoginAlert: $showLoginAlert, userManager: userManager)
                }

                if isMenuOpen {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }
                    SideMenuView(isMenuOpen: $isMenuOpen, userManager: userManager)
                }

                if showCustomAlert {
                    CustomAlertView(alert: selectedAlert ?? "", showCustomAlert: $showCustomAlert)
                }
            }
            .colorScheme(.dark)
            .onAppear {
                fetchAlerts()
            }
            .onReceive(timer) { _ in
                fetchAlerts()
                LocationManager.shared.getLocation { location in
                    guard let location = location else {
                        print("Failed to get location")
                        return
                    }
                    NetworkManager.shared.updateLocation(location: location)
                }
            }
        }
    }

    private func fetchAlerts() {
        NetworkManager.shared.getAlerts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let alerts):
                    self.alerts = alerts
                case .failure(let error):
                    print("Error fetching alerts: \(error.localizedDescription)")
                }
            }
        }
    }
}
