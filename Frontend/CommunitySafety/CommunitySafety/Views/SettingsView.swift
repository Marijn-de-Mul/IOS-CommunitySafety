import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled: Bool = false
    @State private var darkModeEnabled: Bool = false
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            Toggle(isOn: $notificationsEnabled) {
                Text("Enable Notifications")
            }
            .padding()
            
            Toggle(isOn: $darkModeEnabled) {
                Text("Enable Dark Mode")
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}
