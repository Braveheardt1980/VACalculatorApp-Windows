import Foundation

/// Complete build configuration that captures the entire calculation session
/// This allows users to save their work and reload it later with all settings intact
struct BuildConfiguration: Codable, Identifiable {
    let id: UUID
    
    // MARK: - Basic Information
    var name: String
    var description: String
    var createdDate: Date
    var lastModifiedDate: Date
    
    // MARK: - Equipment Configuration
    var equipmentType: String
    var sensorType: String
    var mountingMethod: String
    var rpm: String
    
    // MARK: - Bearing Configuration
    var bearingInfoKnown: Bool
    var bearingCount: Int
    var selectedBearings: [String] // Array of bearing model names
    
    // MARK: - Gearbox Configuration
    var hasGearbox: Bool
    var gearboxInfoLevel: String
    var numberOfShafts: Int
    var gearboxInputRPM: String
    var gearboxOutputRPM: String
    var gearboxStages: Int
    var knownGearTeeth: [String]
    var userProvidedOutputSpeed: Double?
    
    // MARK: - Gearbox Information Questions
    var knowNumberOfShafts: Bool
    var knowGearTeethCount: Bool
    var knowBearingDetails: Bool
    var knowOutputRPM: Bool
    
    // MARK: - Advanced Gearbox Data
    var gearCount: Int
    var outputRPM: String
    var hasOutputRPM: Bool
    var gearTeethData: [String: String]
    var bearingData: [String: String]
    
    // MARK: - Fan/Pump Specific
    var vaneBladeCount: Int
    
    // MARK: - Compressor Specific
    var compressorType: String
    var maleLobeCount: Int
    var femaleLobeCount: Int
    
    // MARK: - Advanced Settings
    var advancedCalculationSettings: AdvancedCalculationSettings
    
    // MARK: - Results (for reference)
    var calculationResults: [APSetDisplayResultData]?
    var gearboxShaftResults: [ShaftCalculationResultsData]?
    
    // MARK: - Initialization
    init(name: String, description: String = "") {
        self.id = UUID()
        self.name = name
        self.description = description
        self.createdDate = Date()
        self.lastModifiedDate = Date()
        
        // Default equipment configuration
        self.equipmentType = ""
        self.sensorType = "Accelerometer"
        self.mountingMethod = "Stud"
        self.rpm = ""
        
        // Default bearing configuration
        self.bearingInfoKnown = false
        self.bearingCount = 2
        self.selectedBearings = Array(repeating: "", count: 5)
        
        // Default gearbox configuration
        self.hasGearbox = false
        self.gearboxInfoLevel = "minimal"
        self.numberOfShafts = 2
        self.gearboxInputRPM = ""
        self.gearboxOutputRPM = ""
        self.gearboxStages = 1
        self.knownGearTeeth = Array(repeating: "", count: 5)
        self.userProvidedOutputSpeed = nil
        
        // Default gearbox information questions
        self.knowNumberOfShafts = false
        self.knowGearTeethCount = false
        self.knowBearingDetails = false
        self.knowOutputRPM = false
        
        // Default advanced gearbox data
        self.gearCount = 2
        self.outputRPM = ""
        self.hasOutputRPM = false
        self.gearTeethData = [:]
        self.bearingData = [:]
        
        // Default fan/pump specific
        self.vaneBladeCount = 0
        
        // Default compressor specific
        self.compressorType = ""
        self.maleLobeCount = 4
        self.femaleLobeCount = 6
        
        // Default advanced settings
        self.advancedCalculationSettings = AdvancedCalculationSettings()
        
        // No results initially
        self.calculationResults = nil
        self.gearboxShaftResults = nil
    }
    
    // MARK: - Simple initializer for Windows basic functionality
    init(equipmentType: String, sensorType: String, mountingMethod: String, 
         rpm: Double, bearingInfoKnown: Bool, bearingCount: Int, selectedBearings: [String]) {
        self.init(name: "Quick Build")
        self.equipmentType = equipmentType
        self.sensorType = sensorType
        self.mountingMethod = mountingMethod
        self.rpm = String(rpm)
        self.bearingInfoKnown = bearingInfoKnown
        self.bearingCount = bearingCount
        self.selectedBearings = selectedBearings
    }
    
    // MARK: - Update Methods
    mutating func updateModificationDate() {
        self.lastModifiedDate = Date()
    }
    
    mutating func updateResults(calculationResults: [APSetDisplayResult]?, gearboxShaftResults: [ShaftCalculationResults]?) {
        self.calculationResults = calculationResults?.map { APSetDisplayResultData(from: $0) }
        self.gearboxShaftResults = gearboxShaftResults?.map { ShaftCalculationResultsData(from: $0) }
        updateModificationDate()
    }
}

// MARK: - Serializable Data Models
// These models are simplified versions for serialization purposes

struct APSetDisplayResultData: Codable {
    let bearingModel: String
    let bearingCount: Int
    let fmax: Double
    let lor: Int
    let shaftRevolutions: Double
    let peakVueHPFilter: Double?
    let gmfFrequency: Double?
    let isValid: Bool
    let validationMessages: [String]
    let rpm: Double
    
    init(from result: APSetDisplayResult) {
        self.bearingModel = result.bearingModel
        self.bearingCount = result.bearingCount
        self.fmax = result.fmax
        self.lor = result.lor
        self.shaftRevolutions = result.shaftRevolutions
        self.peakVueHPFilter = result.peakVueHPFilter
        self.gmfFrequency = result.gmfFrequency
        self.isValid = result.isValid
        self.validationMessages = result.validationMessages
        self.rpm = result.rpm
    }
}

struct ShaftCalculationResultsData: Codable {
    let shaftNumber: Int
    let shaftType: String
    let shaftRPM: Double
    let shaftGMF: Double
    let bearingResults: [APSetDisplayResultData]
    let bearingModels: [String]
    
    init(from result: ShaftCalculationResults) {
        self.shaftNumber = result.shaftNumber
        self.shaftType = result.shaftType
        self.shaftRPM = result.shaftRPM
        self.shaftGMF = result.shaftGMF
        self.bearingResults = result.bearingResults.map { APSetDisplayResultData(from: $0) }
        self.bearingModels = result.bearingModels
    }
}

// Placeholder for ShaftCalculationResults (if not already defined)
struct ShaftCalculationResults {
    let shaftNumber: Int
    let shaftType: String // "Input", "Intermediate", "Output"
    let shaftRPM: Double
    let shaftGMF: Double // Hz
    let bearingResults: [APSetDisplayResult] // Normal + PeakVue for each bearing
    let bearingModels: [String] // Bearing models on this shaft
}

// MARK: - Build Configuration Extensions
extension BuildConfiguration {
    /// Create a build configuration from the current state (simplified for Windows)
    static func fromCurrentState(
        name: String,
        description: String = "",
        equipmentType: String,
        sensorType: String,
        mountingMethod: String,
        rpm: String,
        bearingInfoKnown: Bool,
        bearingCount: Int,
        selectedBearings: [String],
        calculationResults: [APSetDisplayResult]? = nil
    ) -> BuildConfiguration {
        var config = BuildConfiguration(name: name, description: description)
        
        // Equipment configuration
        config.equipmentType = equipmentType
        config.sensorType = sensorType
        config.mountingMethod = mountingMethod
        config.rpm = rpm
        
        // Bearing configuration
        config.bearingInfoKnown = bearingInfoKnown
        config.bearingCount = bearingCount
        config.selectedBearings = selectedBearings
        
        // Results
        config.calculationResults = calculationResults?.map { APSetDisplayResultData(from: $0) }
        
        return config
    }
}