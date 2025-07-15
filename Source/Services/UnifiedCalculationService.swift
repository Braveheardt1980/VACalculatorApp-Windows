import Foundation

// MARK: - Unified Calculation Service

class UnifiedCalculationService {
    
    // MARK: - Singleton
    
    static let shared = UnifiedCalculationService()
    
    // MARK: - Services
    
    // Services use static methods, no instances needed
    
    // MARK: - Main Calculation Method
    
    func calculateUnifiedShaftBearingResults(
        bearingData: BearingData,
        rpm: Double,
        analysisType: AnalysisType,
        sensorType: String,
        mountingMethod: String
    ) -> APSetDisplayResult? {
        
        // Create calculation input
        let input = CalculationInput(
            rpm: rpm,
            bearingData: bearingData,
            analysisType: analysisType,
            sensorType: sensorType,
            mountingMethod: mountingMethod
        )
        
        // Perform calculations based on analysis type
        let result: APSetDisplayResult
        
        switch analysisType {
        case .normal:
            result = calculateNormalAnalysis(input: input)
        case .peakVue:
            result = calculatePeakVueAnalysis(input: input)
        }
        
        // Return result without trends for simplified build
        return result
    }
    
    // MARK: - Normal Analysis
    
    private func calculateNormalAnalysis(input: CalculationInput) -> APSetDisplayResult {
        let rpm = input.rpm
        let bearingData = input.bearingData
        
        // Calculate Fmax and LOR
        let fmax: Double
        let lor: Int
        
        if bearingData.isGeneric {
            // Generic bearing calculations
            fmax = 70.0
            lor = 800
        } else {
            // Specific bearing calculations
            let bpfi = bearingData.bpfi ?? 0
            let maxOrder = max(bearingData.bpfi ?? 0, bearingData.bpfo ?? 0)
            fmax = min(ceil(maxOrder * 3.25), 200.0)
            lor = FormulaService.calculateLOR(fmax: fmax, rpm: rpm)
        }
        
        // Calculate shaft revolutions
        let shaftRevolutions = FormulaService.calculateShaftRevolutions(lor: lor, rpm: rpm)
        
        // Calculate bearing frequencies
        let scaledBPFI = bearingData.bpfi.map { $0 * rpm / 60.0 } ?? 0
        let scaledBPFO = bearingData.bpfo.map { $0 * rpm / 60.0 } ?? 0
        let scaledBSF = bearingData.bsf.map { $0 * rpm / 60.0 } ?? 0
        let scaledFTF = bearingData.ftf.map { $0 * rpm / 60.0 } ?? 0
        
        // Create result
        return APSetDisplayResult(
            id: UUID(),
            rpm: rpm,
            bearingModel: bearingData.designation ?? "Generic Bearing",
            bearingType: bearingData.bearingType ?? "Standard",
            fmax: fmax,
            lor: lor,
            shaftRevolutions: shaftRevolutions,
            isValid: true,
            validationMessages: [],
            calculatedFmax: fmax * rpm / 60.0,
            sensorType: input.sensorType,
            mountingMethod: input.mountingMethod,
            orderBPFI: bearingData.bpfi ?? 0,
            orderBPFO: bearingData.bpfo ?? 0,
            orderBSF: bearingData.bsf ?? 0,
            orderFTF: bearingData.ftf ?? 0,
            scaledBPFI: scaledBPFI,
            scaledBPFO: scaledBPFO,
            scaledBSF: scaledBSF,
            scaledFTF: scaledFTF,
            peakVueHPFilter: nil,
            peakVueCalculatedFmax: nil,
            trendRecommendations: []
        )
    }
    
    // MARK: - PeakVue Analysis
    
    private func calculatePeakVueAnalysis(input: CalculationInput) -> APSetDisplayResult {
        let rpm = input.rpm
        let bearingData = input.bearingData
        
        // Calculate Fmax and LOR for PeakVue
        let fmax: Double
        let lor: Int
        
        if bearingData.isGeneric {
            // Generic bearing PeakVue calculations
            fmax = 30.5
            lor = 400
        } else {
            // Specific bearing PeakVue calculations
            let bpfi = bearingData.bpfi ?? 0
            fmax = min(ceil(bpfi * 1.25), 100.0)
            lor = FormulaService.calculateLOR(fmax: fmax, rpm: rpm)
        }
        
        // Calculate HP filter
        let hpFilter = FilterCalculationService.calculatePeakVueHPFilter(rpm: rpm)
        
        // Calculate shaft revolutions
        let shaftRevolutions = FormulaService.calculateShaftRevolutions(lor: lor, rpm: rpm)
        
        // Create result
        return APSetDisplayResult(
            id: UUID(),
            rpm: rpm,
            bearingModel: "\(bearingData.designation ?? "Generic Bearing") (PeakVue)",
            bearingType: bearingData.bearingType ?? "Standard",
            fmax: fmax,
            lor: lor,
            shaftRevolutions: shaftRevolutions,
            isValid: true,
            validationMessages: [],
            calculatedFmax: nil,
            sensorType: input.sensorType,
            mountingMethod: input.mountingMethod,
            orderBPFI: bearingData.bpfi ?? 0,
            orderBPFO: bearingData.bpfo ?? 0,
            orderBSF: bearingData.bsf ?? 0,
            orderFTF: bearingData.ftf ?? 0,
            scaledBPFI: 0,
            scaledBPFO: 0,
            scaledBSF: 0,
            scaledFTF: 0,
            peakVueHPFilter: hpFilter,
            peakVueCalculatedFmax: fmax * rpm / 60.0,
            trendRecommendations: []
        )
    }
}

// MARK: - Calculation Input Model

struct CalculationInput {
    let rpm: Double
    let bearingData: BearingData
    let analysisType: AnalysisType
    let sensorType: String
    let mountingMethod: String
}

// Note: AnalysisType is defined in APSetDisplayModels.swift