import SwiftUI

struct CreateAlertButtonView: View {
    @State private var selectedTab: Int = 0
    @State private var showAlertView: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    showAlertView = true
                }) {
                    Text("Send Alert")
                        .padding()
                        .frame(width: 300, height: 300)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .padding()
                .sheet(isPresented: $showAlertView) {
                    AlertView(selectedTab: $selectedTab)
                }
            }
        }
    }
}

struct CreateAlertButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAlertButtonView()
    }
}
