import SwiftUI

struct AlertView: View {
    @State private var showOverlay = false
    @State private var severity = 1
    @State private var title = ""
    @State private var description = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            VStack {
                Button(action: {
                    showOverlay = true
                }) {
                    Text("Send Alert")
                        .font(.largeTitle)
                        .padding()
                        .frame(width: 200, height: 200)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .padding()
            }

            if showOverlay {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("New Alert")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Severity: \(severity)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)

                    Picker("Severity", selection: $severity) {
                        ForEach(1..<11) { index in
                            Text("\(index)").tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)

                    TextField("Title", text: $title)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .placeholder(when: title.isEmpty) {
                            Text("Title").foregroundColor(.black)
                        }

                    TextField("Description", text: $description)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .placeholder(when: description.isEmpty) {
                            Text("Description").foregroundColor(.black)
                        }

                    HStack {
                        Button(action: {
                            showOverlay = false
                        }) {
                            Text("Cancel")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            sendAlert()
                        }) {
                            Text("Submit")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray4))
                .cornerRadius(12)
                .shadow(radius: 20)
                .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func sendAlert() {
        NetworkManager.shared.sendAlert(severity: severity, title: title, description: description) { result in
            switch result {
            case .success:
                alertMessage = "Alert sent successfully"
            case .failure(let error):
                alertMessage = "Failed to send alert: \(error.localizedDescription)"
            }
            showAlert = true
            showOverlay = false
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}