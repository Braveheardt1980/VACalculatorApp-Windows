import Foundation

struct BearingInfo: Codable {
    let BPFI: Double
    let BPFO: Double
    let BSF: Double
    let FTF: Double
    let BR_COUNT: Int?  // Number of balls/rollers (optional, may be nil for some bearings)
    
    // Computed properties for compatibility with lowercase naming
    var bpfi: Double { BPFI }
    var bpfo: Double { BPFO }
    var bsf: Double { BSF }
    var ftf: Double { FTF }
    var ballRollerCount: Int? { BR_COUNT }
}

class BearingLookupEngine: ObservableObject {
    @Published private(set) var bearings: [String: BearingInfo] = [:]
    @Published var isLoading = false
    @Published var loadedSources: [String] = []

    /// Master bearing data file
    private let masterBearingFile = "bearings-master"

    init() {
        loadBearings()
    }

    /// Loads bearing data from the master JSON file
    func loadBearings() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let loadedBearings = self.loadBearingsFromFile(fileName: self.masterBearingFile) {
                DispatchQueue.main.async {
                    self.bearings = loadedBearings
                    self.loadedSources = [self.masterBearingFile]
                    self.isLoading = false

                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false

                }
            }
        }
    }

    /// Loads bearings from a specific JSON file
    private func loadBearingsFromFile(fileName: String) -> [String: BearingInfo]? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let parsed = try? JSONDecoder().decode([String: BearingInfo].self, from: data) else {
            return nil
        }
        return parsed
    }

    /// Returns the fault frequencies for a given bearing model
    func getBearingInfo(model: String) -> BearingInfo? {
        return bearings[model]
    }

    /// Returns a sorted list of all available bearing models
    func getAllModels() -> [String] {
        
        return Array(bearings.keys).sorted()
    }

    /// Filters bearing models by brand or type prefix
    func getModelsFiltered(by prefix: String) -> [String] {
        return bearings.keys.filter { $0.lowercased().hasPrefix(prefix.lowercased()) }.sorted()
    }

    /// Get bearing models by series (e.g., "620", "NU", "222")
    func getModelsBySeries(_ series: String) -> [String] {
        return bearings.keys.filter { $0.hasPrefix(series) }.sorted()
    }

    /// Get available bearing series
    func getAvailableSeries() -> [String] {
        let series = Set(bearings.keys.compactMap { model in
            let parts = model.split(separator: " ")
            let bearingNumber = parts.count > 1 ? String(parts[1]) : model
            
            // Extract series from model number
            if bearingNumber.hasPrefix("6") {
                return String(bearingNumber.prefix(3)) // e.g., "620" from "6203"
            } else if bearingNumber.hasPrefix("NU") {
                return "NU"
            } else if bearingNumber.hasPrefix("22") {
                return "22"
            } else if bearingNumber.hasPrefix("32") {
                return "32"
            } else if bearingNumber.hasPrefix("7") {
                return String(bearingNumber.prefix(2)) // e.g., "73" from "7307"
            } else if bearingNumber.hasPrefix("N") {
                return "N"
            }
            return nil
        })
        return Array(series).sorted()
    }
    
    /// Get available manufacturers
    func getAvailableManufacturers() -> [String] {
        let manufacturers = Set(bearings.keys.compactMap { model in
            let parts = model.split(separator: " ")
            return parts.count > 1 ? String(parts[0]).uppercased() : nil
        })
        return Array(manufacturers).sorted()
    }
    
    /// Get bearings by manufacturer
    func getBearingsByManufacturer(_ manufacturer: String) -> [String] {
        return bearings.keys.filter { model in
            let parts = model.split(separator: " ")
            guard parts.count > 1 else { return false }
            return String(parts[0]).uppercased() == manufacturer.uppercased()
        }.sorted()
    }

    /// Get bearing statistics
    func getBearingStats() -> (total: Int, series: Int, manufacturers: Int) {
        return (
            total: bearings.count,
            series: getAvailableSeries().count,
            manufacturers: getAvailableManufacturers().count
        )
    }

    /// Search bearings by model number pattern
    func searchBearings(query: String) -> [String] {
        let lowercaseQuery = query.lowercased()
        return bearings.keys.filter { 
            $0.lowercased().contains(lowercaseQuery) 
        }.sorted()
    }
    
    /// Find bearing by model name (alias for getBearingInfo for compatibility)
    func findBearing(model: String) -> BearingInfo? {
        return getBearingInfo(model: model)
    }
}
