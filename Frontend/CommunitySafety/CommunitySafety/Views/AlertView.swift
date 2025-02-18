import SwiftUI

struct AlertView: View {
    @State private var severity: Int = 1
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showModal: Bool = false

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
                showModal = true
            }) {
                Text("SEND ALERT")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(50)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .sheet(isPresented: $showModal) {
                VStack {
                    Text("Confirm Alert")
                        .font(.headline)
                        .padding()

                    Text("Severity: \(severity)")
                    Text("Title: \(title)")
                    Text("Description: \(description)")

                    HStack {
                        Button(action: {
                            showModal = false
                        }) {
                            Text("Cancel")
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }

                        Button(action: {
                            NetworkManager.shared.createAlert(severity: "\(severity)", title: title, description: description) { result in
                                switch result {
                                case .success(let message):
                                    alertMessage = message
                                case .failure(let error):
                                    alertMessage = error.localizedDescription
                                }
                                showAlert = true
                                showModal = false
                            }
                        }) {
                            Text("Send")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .alert(isPresented: $showAlert) {
                SwiftUI.Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .navigationBarTitle("Create Alert", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            // Action to go back
        }) {
            
        })
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView()
    }
}
