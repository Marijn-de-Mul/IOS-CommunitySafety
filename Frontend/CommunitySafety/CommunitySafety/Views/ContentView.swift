import SwiftUI

@main
struct CommunitySafetyApp: App {
    var body: some Scene {
        
        WindowGroup {
            MainView(isLoggedIn: false)
        }
    }
}
