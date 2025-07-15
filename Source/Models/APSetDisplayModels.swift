import Foundation

// MARK: - AP Set Display Models
// Migrated from SwiftUI original to SwiftCrossUI Windows version

// Custom APSetResult for grouped bearings
struct APSetDisplayResult: Identifiable, Codable {
    let id: UUID
    let bearingModel: String
    let bearingCount: Int
    // Recommended AP Set values (what user should use)
    let fmax: Double
    let lor: Int
    let shaftRevolutions: Double
    let peakVueHPFilter: Double?
    let gmfFrequency: Double?
    // Normal AP Set Calculated/Raw values (what was calculated before rounding/standardizing)
    let calculatedFmax: Double?
    let requiredLOR: Int?
    let calculatedShaftRevs: Double?
    // PeakVue-specific Calculated/Raw values
    let peakVueCalculatedFmax: Double?
    let peakVueRawLOR: Double?
    let peakVueCalculatedShaftRevs: Double?
    // Bearing frequencies (scaled to Hz)
    let scaledBPFI: Double
    let scaledBPFO: Double
    let scaledBSF: Double
    let scaledFTF: Double
    // Original bearing orders (dimensionless coefficients)
    let orderBPFI: Double
    let orderBPFO: Double
    let orderBSF: Double
    let orderFTF: Double
    let isValid: Bool
    let validationMessages: [String]
    // Add RPM for Hz calculations
    let rpm: Double
    // NEW: Fmax details for display (Normal AP Set)
    let bearingBasedFmaxOrders: Double?
    let bearingBasedFmaxHz: Double?
    let gmfBasedFmaxHz: Double?
    // NEW: PeakVue-specific calculated Fmax details
    let peakVueBearingBasedFmaxOrders: Double?
    let peakVueBearingBasedFmaxHz: Double?
    let peakVueGmfBasedFmaxOrders: Double?
    let peakVueGmfBasedFmaxHz: Double?
    let peakVueFallbackFmaxOrders: Double?
    // Trend recommendations
    var trendRecommendations: [TrendRecommendation]
    
    // Convenience initializer for basic calculations
    init(
        id: UUID = UUID(),
        rpm: Double,
        bearingModel: String,
        bearingType: String,
        fmax: Double,
        lor: Int,
        shaftRevolutions: Double,
        isValid: Bool,
        validationMessages: [String],
        calculatedFmax: Double?,
        sensorType: String,
        mountingMethod: String,
        orderBPFI: Double,
        orderBPFO: Double,
        orderBSF: Double,
        orderFTF: Double,
        scaledBPFI: Double,
        scaledBPFO: Double,
        scaledBSF: Double,
        scaledFTF: Double,
        peakVueHPFilter: Double?,
        peakVueCalculatedFmax: Double?,
        trendRecommendations: [TrendRecommendation]
    ) {
        self.id = id
        self.bearingModel = bearingModel
        self.bearingCount = 1
        self.fmax = fmax
        self.lor = lor
        self.shaftRevolutions = shaftRevolutions
        self.peakVueHPFilter = peakVueHPFilter
        self.gmfFrequency = nil
        self.calculatedFmax = calculatedFmax
        self.requiredLOR = nil
        self.calculatedShaftRevs = nil
        self.peakVueCalculatedFmax = peakVueCalculatedFmax
        self.peakVueRawLOR = nil
        self.peakVueCalculatedShaftRevs = nil
        self.scaledBPFI = scaledBPFI
        self.scaledBPFO = scaledBPFO
        self.scaledBSF = scaledBSF
        self.scaledFTF = scaledFTF
        self.orderBPFI = orderBPFI
        self.orderBPFO = orderBPFO
        self.orderBSF = orderBSF
        self.orderFTF = orderFTF
        self.isValid = isValid
        self.validationMessages = validationMessages
        self.rpm = rpm
        self.bearingBasedFmaxOrders = nil
        self.bearingBasedFmaxHz = nil
        self.gmfBasedFmaxHz = nil
        self.peakVueBearingBasedFmaxOrders = nil
        self.peakVueBearingBasedFmaxHz = nil
        self.peakVueGmfBasedFmaxOrders = nil
        self.peakVueGmfBasedFmaxHz = nil
        self.peakVueFallbackFmaxOrders = nil
        self.trendRecommendations = trendRecommendations
    }
}

// Custom bearing structure for user-defined bearings
struct CustomBearing {
    let model: String
    let bpfi: Double
    let bpfo: Double
    let bsf: Double
    let ftf: Double
}

// MARK: - Trend Recommendation Models

enum TrendType: Codable {
    case waveform
    case statistical
    case orderBand(start: Double, end: Double)
    case frequencyBand(centerHz: Double, bandwidthHz: Double)
    case bearingBand(centerOrders: Double, bandwidth: Double)
    case equipmentSpecific(frequency: Double, name: String)
}

enum TrendPriority: Codable {
    case critical
    case high
    case medium
    case low
    
    var description: String {
        switch self {
        case .critical: return "Critical"
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
    
    var color: String {
        switch self {
        case .critical: return "red"
        case .high: return "orange"
        case .medium: return "blue"
        case .low: return "gray"
        }
    }
}

enum AnalysisType: Codable {
    case normal
    case peakVue
}

struct TrendRecommendation: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: TrendType
    let priority: TrendPriority
    let analysisType: AnalysisType
    let description: String
    let frequencyRangeHz: String?
    let frequencyRangeOrders: String?
    let faultAssociation: String
    let isWithinFmax: Bool
    let isResolvable: Bool
    
    var displayName: String {
        if let orders = frequencyRangeOrders, let hz = frequencyRangeHz {
            return "\(name) (\(orders), \(hz))"
        } else if let orders = frequencyRangeOrders {
            return "\(name) (\(orders))"
        } else if let hz = frequencyRangeHz {
            return "\(name) (\(hz))"
        } else {
            return name
        }
    }
    
    var isRecommended: Bool {
        return isWithinFmax && isResolvable
    }
}

// MARK: - Resolution Analysis Models
// ResolutionAnalysis and ResolutionOption are defined in FormulaService.swift

// MARK: - Averaging Recommendation Models

struct AveragingRecommendation {
    let recommended: Int
    let alternatives: [Int]
    let reason: String
    let alternativeGuidance: [Int: String]
}

// MARK: - Windows-Specific Extensions

// Add Windows-specific functionality for future use
extension APSetDisplayResult {
    /// Windows-specific display formatting
    var windowsFormattedDescription: String {
        return "\(bearingModel) - Fmax: \(String(format: "%.1f", fmax)) orders, LOR: \(lor)"
    }
    
    /// Convert to Windows clipboard format
    func toClipboardText() -> String {
        var text = "VA Calculator Results\n"
        text += "Bearing: \(bearingModel) (×\(bearingCount))\n"
        text += "Fmax: \(String(format: "%.1f", fmax)) orders\n"
        text += "LOR: \(lor)\n"
        text += "Shaft Revolutions: \(String(format: "%.1f", shaftRevolutions))\n"
        
        if let pvHP = peakVueHPFilter {
            text += "PeakVue HP Filter: \(String(format: "%.0f", pvHP)) Hz\n"
        }
        
        if !trendRecommendations.isEmpty {
            text += "\nRecommended Trends:\n"
            for trend in trendRecommendations.prefix(5) {
                text += "• \(trend.name)\n"
            }
        }
        
        return text
    }
}

extension TrendRecommendation {
    /// Windows-specific trend formatting
    var windowsDisplayFormat: String {
        let priorityIndicator = priority == .critical ? "⚠️" : priority == .high ? "🔶" : ""
        return "\(priorityIndicator) \(displayName)"
    }
}