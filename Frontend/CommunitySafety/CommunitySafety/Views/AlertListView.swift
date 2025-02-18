import SwiftUI
import Foundation

struct AlertListView: View {
    @Binding var alerts: [Alert]

    var body: some View {
        NavigationView {
            List {
                ForEach(alerts) { alert in
                    VStack(alignment: .leading) {
                        Text(alert.title)
                            .font(.headline)
                        Text(alert.description)
                        Text("Severity: \(alert.severity)")
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let alert = alerts[index]
                        NetworkManager.shared.deleteAlert(String(alert.id)) { result in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    alerts.remove(atOffsets: indexSet)
                                }
                            case .failure(let error):
                                print("Error deleting alert: \(error)")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Alerts")
        }
    }
}
