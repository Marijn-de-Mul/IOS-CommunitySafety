import SwiftUI

struct AlertView: View {
    @State private var showOverlay = false
    @State private var severity = 1
    @State private var title = ""
    @State private var description = ""

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
                            // Implement send alert action
                            showOverlay = false
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
