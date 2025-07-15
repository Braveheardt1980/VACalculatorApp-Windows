import Foundation

/// Service for HP filter calculations and validation
/// Handles all filter selection and optimization logic
struct FilterCalculationService {
    
    // MARK: - Constants
    
    /// Industry-standard HP filter frequencies for stress wave analysis
    static let standardHPFilters = [500.0, 1000.0, 2000.0, 5000.0, 10000.0, 20000.0]
    
    /// Band-pass filter ranges for low-speed applications
    static let standardBandPassFilters = [(20.0, 150.0), (50.0, 300.0), (100.0, 600.0)]
    
    // MARK: - HP Filter Calculation
    
    // Normal AP Sets don't have HP filters - only PeakVue AP Sets do
    
    /// Simple HP filter calculation for basic use
    static func calculatePeakVueHPFilter(rpm: Double) -> Double {
        // Basic calculation: 10x running speed as minimum HP filter
        let runningSpeedHz = rpm / 60.0
        let minimumHPFilter = runningSpeedHz * 10.0
        
        // Select from standard HP filter values
        for filter in standardHPFilters {
            if minimumHPFilter <= filter {
                return filter
            }
        }
        
        return standardHPFilters.last ?? 5000.0
    }
    
    /// Calculate optimal HP filter for PeakVue AP Set - HP Filter must be ≥ Fmax
    /// Uses industry-standard discrete filter values for stress wave analysis
    static func calculatePeakVueHPFilter(bpfi: Double, rpm: Double, equipmentType: String = "") -> (filter: Double, type: String, reason: String) {
        // For PeakVue, HP Filter must be ≥ Fmax
        // Pure bearing calculation: BPFI × 4 orders
        let pureBearingFmaxOrders = bpfi * 4.0
        let runningSpeedHz = rpm / 60.0
        
        // Calculate recommended PeakVue Fmax using pure bearing calculation
        let recommendedPeakVueFmax = FormulaService.recommendPeakVueStandardFmax(calculatedFmax: pureBearingFmaxOrders, rpm: rpm)
        let recommendedFmaxHz = recommendedPeakVueFmax * runningSpeedHz
        
        // HP Filter calculation: also based on 4 × BPFI
        let calculatedHPFilterHz = pureBearingFmaxOrders * runningSpeedHz
        
        // Find the minimum required HP filter (must be ≥ recommended Fmax)
        let minimumRequired = max(calculatedHPFilterHz, recommendedFmaxHz)
        
        // Use FormulaService to select appropriate standard HP filter
        let selectedFilter = FormulaService.selectStandardHPFilter(minimumRequired: minimumRequired)
        
        return (selectedFilter, "High-pass \(Int(selectedFilter)) Hz", "HP Filter selected to meet PeakVue Fmax requirement (\(String(format: "%.0f", recommendedFmaxHz)) Hz)")
    }
    
    /// Calculate HP filter for PeakVue when bearing details are unknown
    /// Uses default order values and converts to Hz, ensuring HP filter ≥ Fmax
    static func calculatePeakVueHPFilterUnknownBearing(rpm: Double, advancedSettings: AdvancedCalculationSettings? = nil) -> (filter: Double, type: String, reason: String) {
        let runningSpeedHz = rpm / 60.0
        
        // Default PeakVue values when bearing unknown
        let defaultFmaxOrders = advancedSettings?.isAdvancedModeEnabled == true ? advancedSettings!.peakVueRPMFallbackOrders : 30.5  // Default PeakVue Fmax in orders
        let defaultHPFilterOrders = advancedSettings?.isAdvancedModeEnabled == true ? advancedSettings!.peakVueRPMFallbackOrders : 30.5  // Default HP filter in orders
        
        // Convert to Hz
        let fmaxHz = defaultFmaxOrders * runningSpeedHz
        let hpFilterHz = defaultHPFilterOrders * runningSpeedHz
        
        // Apply rule: HP filter must be ≥ Fmax
        let minimumRequired = max(hpFilterHz, fmaxHz)
        
        // Use FormulaService to select appropriate standard HP filter
        let selectedFilter = FormulaService.selectStandardHPFilter(minimumRequired: minimumRequired)
        
        return (selectedFilter, "High-pass \(Int(selectedFilter)) Hz", "HP Filter selected to meet Fmax requirement using default PeakVue values")
    }
    
    /// Calculate HP filter for gearbox applications
    /// Ensures filter meets the highest requirement across all measurement points
    static func calculateGearboxHPFilter(gmfResults: [GMFResult]) -> Double {
        guard !gmfResults.isEmpty else { return 1000.0 }
        
        // Find the highest GMF frequency
        let highestGMF = gmfResults.map { $0.gmfFrequency }.max() ?? 0.0
        
        // HP filter should be equal or higher than the highest GMF
        // Use FormulaService to select appropriate standard HP filter
        return FormulaService.selectStandardHPFilter(minimumRequired: highestGMF)
    }
    
    // MARK: - Filter Validation
    
    /// Validate HP filter selection against analysis requirements
    /// Ensures filter meets industry standards for bearing fault detection
    static func validateHPFilterSelection(selectedFilter: Double, filterType: String, bpfi: Double, rpm: Double, isPeakVue: Bool = false, advancedSettings: AdvancedCalculationSettings? = nil) -> (isValid: Bool, confidence: String, details: String) {
        let runningSpeedHz = rpm / 60.0
        let bpfiMultiplier = isPeakVue ? 
            (advancedSettings?.isAdvancedModeEnabled == true ? advancedSettings!.peakVueBPFIMultiplier : 4.0) : 
            (advancedSettings?.isAdvancedModeEnabled == true ? advancedSettings!.normalBPFIMultiplier : 7.0)  // Custom or default multipliers
        let bpfiBasedFilter = bpfiMultiplier * bpfi * runningSpeedHz  // Emerson formula: multiplier × BPFI × RPS
        let minimumRequired = max(bpfiBasedFilter, 10 * runningSpeedHz)
        
        let analysisType = isPeakVue ? "PeakVue" : "Normal"
        
        // Check if filter meets minimum requirements
        if selectedFilter < minimumRequired {
            return (false, "Insufficient", "Filter too low for effective \(analysisType) bearing fault detection")
        }
        
        // Evaluate filter effectiveness
        if selectedFilter >= minimumRequired && selectedFilter <= minimumRequired * 2 {
            return (true, "Optimal", "Filter frequency ideal for \(analysisType) bearing fault analysis")
        } else if selectedFilter <= minimumRequired * 5 {
            return (true, "Good", "Filter frequency suitable for \(analysisType) bearing fault analysis")
        } else {
            return (true, "Acceptable", "Filter frequency may reduce signal strength but still functional for \(analysisType)")
        }
    }
    
    /// Validate filter against sensor and mounting limitations
    static func validateFilterWithSensorMounting(filter: Double, sensorType: SensorType, mountingMethod: MountingMethod) -> (isValid: Bool, warnings: [String]) {
        var warnings: [String] = []
        var isValid = true
        
        // Check sensor frequency range
        let sensorRange = sensorType.frequencyRange
        if filter > sensorRange.max {
            warnings.append("Filter frequency exceeds \(sensorType.rawValue) maximum range")
            isValid = false
        }
        
        // Check mounting method limitations
        let mountingLimit = mountingMethod.frequencyLimitation
        if filter > mountingLimit {
            warnings.append("Filter frequency exceeds \(mountingMethod.rawValue) limitation")
            isValid = false
        }
        
        // Check optimal ranges
        let optimalRange = sensorType.optimalRange
        if filter > optimalRange.max {
            warnings.append("Filter frequency above optimal range for \(sensorType.rawValue)")
        }
        
        return (isValid, warnings)
    }
    
    // MARK: - Filter Recommendations
    
    /// Get filter recommendations based on equipment type
    static func getEquipmentSpecificFilterRecommendations(equipmentType: String, rpm: Double) -> [String] {
        var recommendations: [String] = []
        let runningSpeedHz = rpm / 60.0
        
        switch equipmentType.lowercased() {
        case "motor", "generator":
            recommendations.append("Consider electrical noise filtering at 60Hz and harmonics")
            if runningSpeedHz < 30 {
                recommendations.append("Low-speed motor: Use band-pass filter to isolate bearing frequencies")
            }
            
        case "pump":
            recommendations.append("Monitor for cavitation frequencies above 10kHz")
            recommendations.append("Consider hydraulic noise filtering")
            
        case "fan", "blower":
            recommendations.append("Aerodynamic noise may require higher HP filter")
            recommendations.append("Consider blade pass frequency harmonics")
            
        case "compressor":
            recommendations.append("Pulsation frequencies may interfere with bearing analysis")
            recommendations.append("Use higher HP filter to isolate mechanical faults")
            
        default:
            recommendations.append("Standard HP filter selection based on bearing frequencies")
        }
        
        return recommendations
    }
    
    /// Generate filter selection summary
    static func generateFilterSummary(selectedFilter: Double, filterType: String, reason: String, confidence: String) -> String {
        return """
        Selected Filter: \(filterType)
        Reason: \(reason)
        Confidence: \(confidence)
        
        This filter setting will provide optimal separation of bearing fault frequencies from low-frequency noise and running speed harmonics.
        """
    }
} 