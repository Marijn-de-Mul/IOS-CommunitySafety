import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @State private var alerts: [Alert] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        let annotations = alerts.map { alert -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude)
            annotation.title = alert.title
            annotation.subtitle = "Severity: \(alert.severity)\nDescription: \(alert.description)"
            return annotation
        }
        uiView.addAnnotations(annotations)
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
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }

            if let title = annotation.title, let severity = Int(title?.components(separatedBy: " ").last ?? "0") {
                annotationView?.pinTintColor = colorForSeverity(severity)
            }

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
        NetworkManager.shared.getAlerts { result in
            switch result {
            case .success(let alerts):
                DispatchQueue.main.async {
                    self.alerts = alerts
                }
            case .failure(let error):
                print("Failed to fetch alerts: \(error.localizedDescription)")
            }
        }
    }

    func onAppear() {
        fetchAlerts()
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
