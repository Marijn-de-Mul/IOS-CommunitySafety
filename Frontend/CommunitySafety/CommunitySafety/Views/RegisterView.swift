import SwiftUI

struct RegisterView: View {
    @Binding var isLoggedIn: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false

    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
            Text("CommunitySafety")
                .font(.largeTitle)
                .padding()

            TextField("Username", text: $username)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                UserManager.shared.register(username: username, password: password) { result in
                    switch result {
                    case .success(_):
                        showAlert = true
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }) {
                Text("Register")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .alert(isPresented: $showAlert) {
                SwiftUI.Alert(
                    title: Text("Registration Successful"),
                    message: Text("You can now login with your credentials."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .padding()
    }
}
