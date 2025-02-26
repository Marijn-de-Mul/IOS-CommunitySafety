import SwiftUI

struct CustomAlertView: View {
    var alert: String
    @Binding var showCustomAlert: Bool

    var body: some View {
        VStack {
            Text("Thank you for reporting: \(alert)")
                .padding()
            Button(action: {
                showCustomAlert = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(5)
            }
        }
        .frame(width: 300, height: 200)
        .background(Color.black)
        .cornerRadius(5)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.blue, lineWidth: 2)
        )
    }
}
