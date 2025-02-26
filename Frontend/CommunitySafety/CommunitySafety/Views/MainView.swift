import SwiftUI

struct MainView: View {
    @State private var isLoggedIn: Bool
    @State private var isMenuOpen = false
    @State private var showAlert = false
    @State private var showSheet = false
    @State private var showCustomAlert = false
    @State private var selectedAlert: String?
    @State private var alerts: [Alert] = []
    @State private var showLoginAlert = false
    @ObservedObject private var userManager = UserManager.shared

    init(isLoggedIn: Bool) {
        self._isLoggedIn = State(initialValue: isLoggedIn)
    }

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
                    SideMenuView(isMenuOpen: $isMenuOpen)
                        .zIndex(1)
                }

                if showCustomAlert {
                    CustomAlertView(alert: selectedAlert ?? "", showCustomAlert: $showCustomAlert)
                        .zIndex(2)
                }
            }
        }
    }
}
