import SwiftUI

struct SideMenuView: View {
    @Binding var isMenuOpen: Bool
    @ObservedObject var userManager: UserManager
    @State private var alerts: [Alert] = []
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    if userManager.currentUser != nil {
                        Button(action: {
                            userManager.logout()
                        }) {
                            Text("Logout")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                        }
                    } else {
                        NavigationLink(destination: LoginView(isLoggedIn: $userManager.isLoggedIn)) {
                            Text("Login/Register")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                        }
                    }
                    Divider()
                        .background(Color.white)
                    NavigationLink(destination: AlertListView(alerts: $alerts)) {
                        Text("Alert List")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                    }
                    Divider()
                        .background(Color.white)
                    Button(action: {
                        // Action for Feedback
                    }) {
                        Text("Feedback")
                            .foregroundColor(.gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                    }
                    .disabled(true)
                    Divider()
                        .background(Color.white)
                    Button(action: {
                        // Action for Settings
                    }) {
                        Text("Settings")
                            .foregroundColor(.gray)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                    }
                    .disabled(true)
                    Divider()
                        .background(Color.white)
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.6)
                .background(Color.black)
                .offset(x: isMenuOpen ? 0 : -geometry.size.width * 0.6)
                .shadow(radius: 5)
                Spacer()
            }
            .background(Color.black.opacity(0.3).onTapGesture {
                withAnimation {
                    isMenuOpen.toggle()
                }
            })
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            fetchAlerts()
        }
        .onReceive(timer) { _ in
            fetchAlerts()
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
