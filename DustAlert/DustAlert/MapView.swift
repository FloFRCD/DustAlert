import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var mapView: MKMapView
    @Binding var dustData: [DustData]

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)
        
        for data in dustData {
            let coordinate = CLLocationCoordinate2D(latitude: data.latitude.first ?? 0.0, longitude: data.longitude.first ?? 0.0)
            let dustLevel = data.averageDustLevel
            
            // Create annotation
            let annotation = MKPointAnnotation()
            annotation.title = "Dust Level: \(dustLevel)"
            annotation.subtitle = data.readableDate
            annotation.coordinate = coordinate
            uiView.addAnnotation(annotation)
            
            // Create overlay (e.g., circle) to represent dust level
            let circle = MKCircle(center: coordinate, radius: dustLevel * 1000) // Adjust radius as needed
            uiView.addOverlay(circle)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
                circleRenderer.strokeColor = .red
                circleRenderer.fillColor = UIColor.red.withAlphaComponent(0.1)
                circleRenderer.lineWidth = 1
                return circleRenderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
