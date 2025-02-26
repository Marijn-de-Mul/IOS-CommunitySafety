import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var alerts: [Alert]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)

        for alert in alerts {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude)
            annotation.title = alert.title
            uiView.addAnnotation(annotation)
        }
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
            if annotation is MKUserLocation {
                return nil
            }

            let identifier = "alertPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView

            if annotationView == nil {
                annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            if let title = annotation.title ?? nil, let systemImage = UIImage(systemName: title) {
                let imageView = UIImageView(image: systemImage)
                imageView.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
                annotationView?.addSubview(imageView)
            }

            return annotationView
        }

        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            let userLocationView = mapView.view(for: userLocation)
            userLocationView?.image = UIImage(named: "blue_circle")
        }
    }
}

class CustomAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue else { return }
            let size = CGSize(width: 40, height: 60)
            self.image = drawCustomPinImage(size: size)
            self.centerOffset = CGPoint(x: 0, y: -size.height / 2)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        } else {
            self.transform = CGAffineTransform.identity
        }
    }
}

func drawCustomPinImage(size: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()!

    context.setFillColor(UIColor.red.cgColor)
    context.move(to: CGPoint(x: size.width / 2, y: size.height))
    context.addCurve(to: CGPoint(x: 0, y: size.height / 2),
                     control1: CGPoint(x: size.width / 2, y: size.height - 10),
                     control2: CGPoint(x: 0, y: size.height / 2 + 10))
    context.addArc(center: CGPoint(x: size.width / 2, y: size.height / 2),
                   radius: size.width / 2,
                   startAngle: CGFloat.pi,
                   endAngle: 0,
                   clockwise: false)
    context.addCurve(to: CGPoint(x: size.width / 2, y: size.height),
                     control1: CGPoint(x: size.width, y: size.height / 2 + 10),
                     control2: CGPoint(x: size.width / 2, y: size.height - 10))
    context.closePath()
    context.fillPath()

    context.setFillColor(UIColor.white.cgColor)
    context.addEllipse(in: CGRect(x: size.width / 4, y: size.height / 4, width: size.width / 2, height: size.width / 2))
    context.fillPath()

    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}
