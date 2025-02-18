import SwiftUI

struct MainView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationView {
            TabView {
                CreateAlertButtonView()
                    .tabItem {
                        Label("Alert", systemImage: "exclamationmark.circle")
                    }
                MapView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
            }
            .navigationBarItems(trailing: Button("Logout") {
                isLoggedIn = false
            })
        }
    }
}
