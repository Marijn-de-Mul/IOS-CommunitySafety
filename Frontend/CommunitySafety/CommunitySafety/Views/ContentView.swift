import SwiftUI

@main
struct CommunitySafetyApp: App {
    @ObservedObject var userManager = UserManager.shared
    
    init() {
        userManager.checkTokenValidity()
    }
        
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
