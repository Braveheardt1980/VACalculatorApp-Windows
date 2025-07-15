import Foundation

// MARK: - Build Manager

class BuildManager {
    
    // MARK: - Singleton
    
    static let shared = BuildManager()
    
    // MARK: - Properties
    
    private var savedBuilds: [SavedBuild] = []
    private let userDefaults = UserDefaults.standard
    private let savedBuildsKey = "VACalculator.SavedBuilds"
    
    // MARK: - Initialization
    
    private init() {
        loadSavedBuilds()
    }
    
    // MARK: - Public Methods
    
    func saveBuild(_ build: SavedBuild) {
        savedBuilds.append(build)
        persistBuilds()
    }
    
    func getAllBuilds() -> [SavedBuild] {
        return savedBuilds
    }
    
    func getBuild(by id: UUID) -> SavedBuild? {
        return savedBuilds.first { $0.id == id }
    }
    
    func deleteBuild(by id: UUID) {
        savedBuilds.removeAll { $0.id == id }
        persistBuilds()
    }
    
    func updateBuild(_ build: SavedBuild) {
        if let index = savedBuilds.firstIndex(where: { $0.id == build.id }) {
            savedBuilds[index] = build
            persistBuilds()
        }
    }
    
    // MARK: - Export Methods
    
    func exportBuildAsText(_ build: SavedBuild) -> String {
        var text = "VA Calculator Build Report\n"
        text += "========================\n\n"
        
        text += "Build Name: \(build.name)\n"
        text += "Date Created: \(formatDate(build.dateCreated))\n"
        text += "Equipment Type: \(build.configuration.equipmentType)\n"
        text += "Operating Speed: \(Int(build.configuration.rpm)) RPM\n"
        text += "Sensor: \(build.configuration.sensorType) - \(build.configuration.mountingMethod)\n\n"
        
        text += "AP SET RESULTS\n"
        text += "--------------\n\n"
        
        for result in build.results {
            text += result.toClipboardText()
            text += "\n---\n\n"
        }
        
        return text
    }
    
    func exportBuildAsJSON(_ build: SavedBuild) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            return try encoder.encode(build)
        } catch {
            print("Failed to encode build: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSavedBuilds() {
        guard let data = userDefaults.data(forKey: savedBuildsKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            savedBuilds = try decoder.decode([SavedBuild].self, from: data)
        } catch {
            print("Failed to load saved builds: \(error)")
        }
    }
    
    private func persistBuilds() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(savedBuilds)
            userDefaults.set(data, forKey: savedBuildsKey)
        } catch {
            print("Failed to save builds: \(error)")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Saved Build Model

struct SavedBuild: Codable, Identifiable {
    let id: UUID
    let name: String
    let dateCreated: Date
    let configuration: BuildConfiguration
    let results: [APSetDisplayResult]
    let notes: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        dateCreated: Date = Date(),
        configuration: BuildConfiguration,
        results: [APSetDisplayResult],
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.dateCreated = dateCreated
        self.configuration = configuration
        self.results = results
        self.notes = notes
    }
}

// MARK: - Build Configuration Extension for Codable

extension BuildConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case equipmentType
        case sensorType
        case mountingMethod
        case rpm
        case bearingInfoKnown
        case bearingCount
        case selectedBearings
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        equipmentType = try container.decode(String.self, forKey: .equipmentType)
        sensorType = try container.decode(String.self, forKey: .sensorType)
        mountingMethod = try container.decode(String.self, forKey: .mountingMethod)
        rpm = try container.decode(Double.self, forKey: .rpm)
        bearingInfoKnown = try container.decode(Bool.self, forKey: .bearingInfoKnown)
        bearingCount = try container.decode(Int.self, forKey: .bearingCount)
        selectedBearings = try container.decode([String].self, forKey: .selectedBearings)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(equipmentType, forKey: .equipmentType)
        try container.encode(sensorType, forKey: .sensorType)
        try container.encode(mountingMethod, forKey: .mountingMethod)
        try container.encode(rpm, forKey: .rpm)
        try container.encode(bearingInfoKnown, forKey: .bearingInfoKnown)
        try container.encode(bearingCount, forKey: .bearingCount)
        try container.encode(selectedBearings, forKey: .selectedBearings)
    }
}