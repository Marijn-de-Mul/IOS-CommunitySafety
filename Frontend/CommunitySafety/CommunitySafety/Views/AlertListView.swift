import SwiftUI

struct AlertListView: View {
    @Binding var alerts: [Alert]
    @ObservedObject private var userManager = UserManager.shared
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            List {
                ForEach(alerts) { alert in
                    VStack(alignment: .leading) {
                        Text(alert.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(alert.description)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.black)
                }
                .onDelete(perform: deleteAlert)
            }
            .navigationBarTitle("Alerts")
            .navigationBarItems(trailing: EditButton())
            .background(Color.black)
            .alert(isPresented: $showAlert) {
                SwiftUI.Alert(
                    title: Text("Not Logged In"),
                    message: Text("You cannot delete alerts when not logged in."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .colorScheme(.dark)
    }

    private func deleteAlert(at offsets: IndexSet) {
        guard userManager.isLoggedIn else {
            showAlert = true
            return
        }

        offsets.forEach { index in
            let alert = alerts[index]
            NetworkManager.shared.deleteAlert(String(alert.id)) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        alerts.remove(at: index)
                    case .failure(let error):
                        print("Error deleting alert: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func formattedCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: Date())
    }
}
