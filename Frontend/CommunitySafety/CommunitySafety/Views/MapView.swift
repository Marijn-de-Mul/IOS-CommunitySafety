import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var alerts: [Alert]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var timer: Timer?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        print("MapView created")
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        print("updateUIView called")
        uiView.removeAnnotations(uiView.annotations)
        let annotations = alerts.map { alert -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude)
            annotation.title = alert.title
            annotation.subtitle = "Severity: \(alert.severity)\nDescription: \(alert.description)"
            print("Creating annotation for alert: \(alert)")
            return annotation
        }
        uiView.addAnnotations(annotations)
        print("Annotations added: \(annotations.count)")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
        
            let identifier = "Alert"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }
        
            if let title = annotation.title, let severity = Int(title?.components(separatedBy: " ").last ?? "0") {
                annotationView?.markerTintColor = colorForSeverity(severity)
            }
        
            print("Annotation view created for annotation: \(annotation)")
            return annotationView
        }
        
        private func colorForSeverity(_ severity: Int) -> UIColor {
            switch severity {
            case 1: return .blue
            case 2: return .cyan
            case 3: return .green
            case 4: return .yellow
            case 5: return .orange
            case 6: return .red
            case 7: return .purple
            case 8: return .brown
            case 9: return .magenta
            case 10: return .black
            default: return .gray
            }
        }
    }

    private func fetchAlerts() {
        print("Fetching alerts")
        NetworkManager.shared.getAlerts { result in
            switch result {
            case .success(let newAlerts):
                DispatchQueue.main.async {
                    var uniqueAlerts = self.alerts
                    for newAlert in newAlerts {
                        if !uniqueAlerts.contains(where: { $0.id == newAlert.id }) {
                            uniqueAlerts.append(newAlert)
                        }
                    }
                    self.alerts = uniqueAlerts
                    print("Alerts fetched: \(self.alerts)")
                }
            case .failure(let error):
                print("Failed to fetch alerts: \(error.localizedDescription)")
                if let nsError = error as NSError?, let rawData = nsError.userInfo["rawData"] as? Data {
                    print("Raw data: \(String(data: rawData, encoding: .utf8) ?? "N/A")")
                }
            }
        }
    }

    func startTimer() {
        print("Starting timer")
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            fetchAlerts()
        }
    }

    func stopTimer() {
        print("Stopping timer")
        timer?.invalidate()
        timer = nil
    }

    func onAppear() {
        print("MapView appeared")
        fetchAlerts()
        startTimer()
    }

    func onDisappear() {
        print("MapView disappeared")
        stopTimer()
    }
}
