import SwiftUI

struct AlertView: View {
    @Binding var selectedTab: Int
    @State private var severity: Int = 1
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isButtonDisabled: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Picker("Severity", selection: $severity) {
                ForEach(1..<11) { index in
                    Text("\(index)").tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding()

            TextField("Title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                isButtonDisabled = true
                NetworkManager.shared.createAlert(severity: "\(severity)", title: title, description: description) { result in
                    switch result {
                    case .success(let message):
                        alertMessage = message
                    case .failure(let error):
                        alertMessage = error.localizedDescription
                    }
                    showAlert = true
                    selectedTab = 0 // Navigate back to CreateAlertButtonView
                    isButtonDisabled = false
                    presentationMode.wrappedValue.dismiss() // Go back to ParentView
                }
            }) {
                Text("Send")
                    .padding()
                    .background(isButtonDisabled ? Color.gray : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isButtonDisabled)
            .alert(isPresented: $showAlert) {
                SwiftUI.Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .navigationBarTitle("Create Alert", displayMode: .inline)
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(selectedTab: .constant(0))
    }
}
