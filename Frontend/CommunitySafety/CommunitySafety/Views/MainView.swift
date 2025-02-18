import SwiftUI

struct MainView: View {
    @Binding var isLoggedIn: Bool
    @State private var alerts: [Alert] = []
    @State private var showAlertList = false

    var body: some View {
        NavigationView {
            VStack {
                TabView {
                    CreateAlertButtonView()
                        .tabItem {
                            Label("Alert", systemImage: "exclamationmark.circle")
                        }
                    MapView(alerts: $alerts)
                        .tabItem {
                            Label("Map", systemImage: "map")
                        }
                        .onAppear {
                            MapView(alerts: $alerts).onAppear()
                        }
                        .onDisappear {
                            MapView(alerts: $alerts).onDisappear()
                        }
                }
                Button(action: {
                    showAlertList.toggle()
                }) {
                    Text("Show Alerts")
                }
                .sheet(isPresented: $showAlertList) {
                    AlertListView(alerts: $alerts)
                }
            }
            .navigationTitle("CommunitySafety")
            .navigationBarItems(trailing: Button("Logout") {
                isLoggedIn = false
            })
        }
    }
}
