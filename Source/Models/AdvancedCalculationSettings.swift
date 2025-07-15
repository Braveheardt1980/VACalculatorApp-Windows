import Foundation

/// Advanced calculation settings for professional users
/// Default values match current FormulaService constants - NO BEHAVIOR CHANGE when disabled
struct AdvancedCalculationSettings: Codable {
    
    // MARK: - Advanced Mode Control
    
    /// Master switch for advanced mode - OFF by default (maintains current behavior)
    var isAdvancedModeEnabled: Bool = false
    
    // MARK: - Normal AP Set Multipliers
    
    /// BPFI multiplier for Normal AP Set (Industry Standard: 5-12x, Worldwide: 7x)
    var normalBPFIMultiplier: Double = 7.0  // Matches FormulaService.bpfiMultiplier
    
    /// GMF multiplier for Normal AP Set (Industry Standard: 2-5x, Worldwide: 3.5x) 
    var normalGMFMultiplier: Double = 3.5   // Matches FormulaService.gmfMultiplier
    
    /// RPM fallback for Normal AP Set when no bearing data (Industry Standard: 60-100 orders)
    var normalRPMFallbackOrders: Double = 70.0  // Matches FormulaService.normalFallbackFmaxOrders
    
    // MARK: - PeakVue AP Set Multipliers
    
    /// BPFI multiplier for PeakVue AP Set (Industry Standard: 3-6x, Worldwide: 4x)
    var peakVueBPFIMultiplier: Double = 4.0  // Matches FormulaService.peakVueBpfiMultiplier
    
    /// RPM fallback for PeakVue AP Set when no bearing data (Industry Standard: 25-40 orders)
    var peakVueRPMFallbackOrders: Double = 30.0  // Matches FormulaService.peakVueFallbackFmaxOrders
    
    // MARK: - Validation Ranges (Based on Industry Research)
    
    static let bpfiMultiplierRange: ClosedRange<Double> = 4.0...15.0
    static let gmfMultiplierRange: ClosedRange<Double> = 2.0...5.0
    static let rpmFallbackRange: ClosedRange<Double> = 50.0...100.0
    static let peakVueBpfiMultiplierRange: ClosedRange<Double> = 3.0...6.0
    static let peakVueRpmFallbackRange: ClosedRange<Double> = 25.0...40.0
    
    // MARK: - Industry Standards Information
    
    struct IndustryStandards {
        static let normalBPFI = (
            standard: 7.0,
            range: "5-12x",
            sources: "ISO 13373-7, API 670, NEMA MG-1"
        )
        
        static let normalGMF = (
            standard: 3.5,
            range: "2-5x", 
            sources: "AGMA 6000, ISO 8579"
        )
        
        static let normalRPMFallback = (
            standard: 70.0,
            range: "60-100 orders",
            sources: "ISO 10816, API Standards, SKF Guidelines"
        )
        
        static let peakVueBPFI = (
            standard: 4.0,
            range: "3-6x",
            sources: "Emerson/CSI Standards, SKF Research"
        )
        
        static let peakVueRPMFallback = (
            standard: 30.0,
            range: "25-40 orders", 
            sources: "PeakVue Analysis Standards"
        )
    }
    
    // MARK: - Validation Methods
    
    /// Validates a multiplier value and provides industry guidance
    static func validateMultiplier(_ value: Double, for parameter: String) -> ValidationResult {
        switch parameter {
        case "normalBPFI":
            return ValidationResult(
                value: value,
                isInRange: bpfiMultiplierRange.contains(value),
                suggestedRange: bpfiMultiplierRange,
                industryStandard: IndustryStandards.normalBPFI.standard,
                industryRange: IndustryStandards.normalBPFI.range,
                sources: IndustryStandards.normalBPFI.sources
            )
        case "normalGMF":
            return ValidationResult(
                value: value,
                isInRange: gmfMultiplierRange.contains(value),
                suggestedRange: gmfMultiplierRange,
                industryStandard: IndustryStandards.normalGMF.standard,
                industryRange: IndustryStandards.normalGMF.range,
                sources: IndustryStandards.normalGMF.sources
            )
        case "normalRPMFallback":
            return ValidationResult(
                value: value,
                isInRange: rpmFallbackRange.contains(value),
                suggestedRange: rpmFallbackRange,
                industryStandard: IndustryStandards.normalRPMFallback.standard,
                industryRange: IndustryStandards.normalRPMFallback.range,
                sources: IndustryStandards.normalRPMFallback.sources
            )
        case "peakVueBPFI":
            return ValidationResult(
                value: value,
                isInRange: peakVueBpfiMultiplierRange.contains(value),
                suggestedRange: peakVueBpfiMultiplierRange,
                industryStandard: IndustryStandards.peakVueBPFI.standard,
                industryRange: IndustryStandards.peakVueBPFI.range,
                sources: IndustryStandards.peakVueBPFI.sources
            )
        case "peakVueRPMFallback":
            return ValidationResult(
                value: value,
                isInRange: peakVueRpmFallbackRange.contains(value),
                suggestedRange: peakVueRpmFallbackRange,
                industryStandard: IndustryStandards.peakVueRPMFallback.standard,
                industryRange: IndustryStandards.peakVueRPMFallback.range,
                sources: IndustryStandards.peakVueRPMFallback.sources
            )
        default:
            return ValidationResult(value: value, isInRange: true, suggestedRange: 0...100, industryStandard: value, industryRange: "Unknown", sources: "")
        }
    }
    
    // MARK: - Default Instance
    
    /// Returns default settings that match current FormulaService behavior exactly
    static let standard = AdvancedCalculationSettings()
}

/// Validation result for advanced settings with industry guidance
struct ValidationResult {
    let value: Double
    let isInRange: Bool
    let suggestedRange: ClosedRange<Double>
    let industryStandard: Double
    let industryRange: String
    let sources: String
    
    var isVeryHigh: Bool { value > suggestedRange.upperBound * 1.5 }
    var isVeryLow: Bool { value < suggestedRange.lowerBound * 0.5 }
    
    var warningLevel: ValidationWarningLevel {
        if isVeryHigh || isVeryLow { return .critical }
        if !isInRange { return .warning }
        return .none
    }
}

enum ValidationWarningLevel {
    case none
    case warning  
    case critical
}