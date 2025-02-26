import SwiftUI

struct AlertButtonView: View {
    @Binding var showSheet: Bool
    @Binding var showLoginAlert: Bool
    @ObservedObject var userManager: UserManager

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                if userManager.currentUser != nil {
                    showSheet.toggle()
                } else {
                    showLoginAlert = true
                }
            }) {
                Image(systemName: "bell")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(1.0))
                    .cornerRadius(5)
                    .font(.system(size: 60))
            }
            .sheet(isPresented: $showSheet) {
                AlertSheetView(showSheet: $showSheet, showCustomAlert: .constant(false), selectedAlert: .constant(nil), alerts: .constant([]))
            }
            .padding()
            .alert(isPresented: $showLoginAlert) {
                SwiftUI.Alert(
                    title: Text("Login Required"),
                    message: Text("Please login to send alerts."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
