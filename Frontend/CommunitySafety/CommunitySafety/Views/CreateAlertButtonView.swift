import SwiftUI

struct CreateAlertButtonView: View {
    @State private var showAlertView = false

    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    showAlertView = true
                }) {
                    Text("CREATE ALERT")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 200)
                        .background(Color.red)
                        .clipShape(Circle())
                        .padding()
                }
                .background(
                    NavigationLink(destination: AlertView(), isActive: $showAlertView) {
                        EmptyView()
                    }
                )
            }
        }
    }
}

struct CreateAlertButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAlertButtonView()
    }
}
