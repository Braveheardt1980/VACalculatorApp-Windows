import Foundation

// MARK: - Sensor and Mounting Models

/// Sensor type enumeration
enum SensorType: String, CaseIterable {
    case accelerometer = "Accelerometer"
    case velocityProbe = "Velocity Probe"
    case proximityProbe = "Proximity Probe"
    
    var frequencyRange: (min: Double, max: Double) {
        switch self {
        case .accelerometer:
            return (10.0, 80000.0)
        case .velocityProbe:
            return (10.0, 2000.0)
        case .proximityProbe:
            return (0.1, 1000.0)
        }
    }
    
    var optimalRange: (min: Double, max: Double) {
        switch self {
        case .accelerometer:
            return (100.0, 20000.0)
        case .velocityProbe:
            return (10.0, 1000.0)
        case .proximityProbe:
            return (1.0, 200.0)
        }
    }
}

/// Mounting method enumeration
enum MountingMethod: String, CaseIterable {
    case stud = "Stud Mount"
    case magnet = "Magnetic Mount"
    case handheld = "Handheld"
    case triaxial = "Triaxial Mount"
    
    var frequencyLimitation: Double {
        switch self {
        case .stud:
            return 80000.0
        case .magnet:
            return 2000.0
        case .handheld:
            return 1000.0
        case .triaxial:
            return 10000.0
        }
    }
    
    var reliability: String {
        switch self {
        case .stud:
            return "Excellent"
        case .magnet:
            return "Good"
        case .handheld:
            return "Fair"
        case .triaxial:
            return "Very Good"
        }
    }
}

// MARK: - Gearbox Models (Basic definitions needed for compilation)

/// GMF calculation result
struct GMFResult {
    let stageName: String
    let gmfFrequency: Double
    let drivingGearTeeth: Int
    let drivenGearTeeth: Int
    let inputRPM: Double
    let outputRPM: Double
    let hasWarnings: Bool
    let warnings: [String]
    
    init(stageName: String, gmfFrequency: Double, drivingGearTeeth: Int, drivenGearTeeth: Int, 
         inputRPM: Double, outputRPM: Double, hasWarnings: Bool = false, warnings: [String] = []) {
        self.stageName = stageName
        self.gmfFrequency = gmfFrequency
        self.drivingGearTeeth = drivingGearTeeth
        self.drivenGearTeeth = drivenGearTeeth
        self.inputRPM = inputRPM
        self.outputRPM = outputRPM
        self.hasWarnings = hasWarnings
        self.warnings = warnings
    }
}