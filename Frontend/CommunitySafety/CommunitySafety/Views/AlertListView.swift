import SwiftUI

struct AlertListView: View {
    @Binding var alerts: [Alert]

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
        }
        .colorScheme(.dark)
    }

    private func deleteAlert(at offsets: IndexSet) {
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
}
