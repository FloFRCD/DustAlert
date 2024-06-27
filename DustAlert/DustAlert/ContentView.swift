import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var mapView = MKMapView()

    var body: some View {
        MapViewRepresentable(mapView: $mapView, dustData: $viewModel.dustData)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                viewModel.checkLocationAuthorization()
            }
    }
}
