import SwiftUI
import MapKit

struct ContentView: View {
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainView(isLoggedIn: $isLoggedIn)
        } else {
            NavigationView {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}
