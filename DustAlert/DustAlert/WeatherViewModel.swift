import Foundation
import Combine
import CoreLocation

class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var dustData: [DustData] = []
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        checkLocationAuthorization()
    }

    func checkLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Afficher une alerte pour indiquer à l'utilisateur d'activer les services de localisation
            print("Les services de localisation ne sont pas activés")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            // Gérer le cas où l'utilisateur a refusé la permission de localisation
            print("Permission de localisation refusée ou restreinte")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("Statut d'autorisation inconnu")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        fetchDustData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }

    func fetchDustData(latitude: Double, longitude: Double) {
        let apiKey = "20567:22ac042e-76b2-4f80-b3f6-46886d357a7d"
        let urlString = "https://ads.atmosphere.copernicus.eu/api/v2/services?service=yourServiceName&lat=\(latitude)&lon=\(longitude)"
        
        guard let url = URL(string: urlString) else {
            print("URL invalide")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Basic \(apiKey.data(using: .utf8)!.base64EncodedString())", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Erreur lors de la récupération des données: \(error?.localizedDescription ?? "Erreur inconnue")")
                return
            }

            // Afficher les données brutes pour débogage
            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                print("Réponse JSON: \(json)")
            }

            // Analyser les données JSON
            if let responseData = try? JSONDecoder().decode(CAMSResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.dustData = responseData.forecasts
                }
            } else {
                print("Erreur lors de l'analyse des données")
            }
        }
        task.resume()
    }
}
