import Foundation

func loadDustData() -> [String: DustData]? {
    if let url = Bundle.main.url(forResource: "tunis_dust_2024_combined", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let dustForecast = try decoder.decode([String: DustData].self, from: data)
            return dustForecast
        } catch {
            print("Erreur lors du chargement du fichier JSON: \(error)")
        }
    }
    return nil
}
