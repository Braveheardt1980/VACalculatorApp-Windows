import Foundation

// MARK: - Trend Recommendation Service

struct TrendRecommendationService {
    
    // MARK: - Main Trend Generation
    
    /// Generate intelligent trend recommendations based on calculated AP Set parameters
    static func generateTrendRecommendations(
        for result: APSetDisplayResult,
        equipmentType: String? = nil,
        vaneBladeCount: Int? = nil,
        analysisType: AnalysisType
    ) -> [TrendRecommendation] {
        
        var recommendations: [TrendRecommendation] = []
        
        // Get the appropriate Fmax for validation
        let fmaxOrders = getFmaxInOrders(for: result, analysisType: analysisType)
        let fmaxHz = fmaxOrders * (result.rpm / 60.0)
        let binWidthHz = fmaxHz / Double(result.lor)
        
        switch analysisType {
        case .normal:
            recommendations.append(contentsOf: generateNormalTrends(
                result: result,
                fmaxOrders: fmaxOrders,
                fmaxHz: fmaxHz,
                binWidthHz: binWidthHz
            ))
            
        case .peakVue:
            recommendations.append(contentsOf: generatePeakVueTrends(
                result: result,
                fmaxOrders: fmaxOrders,
                fmaxHz: fmaxHz,
                binWidthHz: binWidthHz
            ))
        }
        
        // Add equipment-specific trends
        if let equipmentType = equipmentType {
            recommendations.append(contentsOf: generateEquipmentSpecificTrends(
                equipmentType: equipmentType,
                vaneBladeCount: vaneBladeCount,
                result: result,
                fmaxOrders: fmaxOrders,
                fmaxHz: fmaxHz,
                binWidthHz: binWidthHz,
                analysisType: analysisType
            ))
        }
        
        // Add bearing-specific trends if bearing info is available
        if result.scaledBPFI > 0 {
            recommendations.append(contentsOf: generateBearingSpecificTrends(
                result: result,
                fmaxOrders: fmaxOrders,
                fmaxHz: fmaxHz,
                binWidthHz: binWidthHz,
                analysisType: analysisType
            ))
        }
        
        return recommendations.sorted { $0.priority.rawValue < $1.priority.rawValue }
    }
    
    // MARK: - Normal AP Set Trends
    
    private static func generateNormalTrends(
        result: APSetDisplayResult,
        fmaxOrders: Double,
        fmaxHz: Double,
        binWidthHz: Double
    ) -> [TrendRecommendation] {
        
        var trends: [TrendRecommendation] = []
        
        // Always include core waveform trends
        trends.append(TrendRecommendation(
            name: "Waveform Peak-Peak",
            type: .waveform,
            priority: .high,
            analysisType: .normal,
            description: "Time waveform peak-to-peak amplitude",
            frequencyRangeHz: nil,
            frequencyRangeOrders: nil,
            faultAssociation: "Impacting, severity detection, bearing condition",
            isWithinFmax: true,
            isResolvable: true
        ))
        
        trends.append(TrendRecommendation(
            name: "Crest Factor",
            type: .statistical,
            priority: .high,
            analysisType: .normal,
            description: "Ratio of peak to RMS amplitude",
            frequencyRangeHz: nil,
            frequencyRangeOrders: nil,
            faultAssociation: "Bearing condition, impacting detection",
            isWithinFmax: true,
            isResolvable: true
        ))
        
        trends.append(TrendRecommendation(
            name: "Overall RMS",
            type: .statistical,
            priority: .critical,
            analysisType: .normal,
            description: "Total vibration energy across frequency range",
            frequencyRangeHz: "0-\(String(format: "%.1f", fmaxHz)) Hz",
            frequencyRangeOrders: "0-\(String(format: "%.1f", fmaxOrders)) orders",
            faultAssociation: "General machine condition, trending",
            isWithinFmax: true,
            isResolvable: true
        ))
        
        // Order-based frequency bands (following AMS methodology)
        let orderBands = [
            (name: "Sub-synchronous", start: 0.0, end: 0.8, priority: TrendPriority.medium, 
             description: "Belt drives, oil whirl, speed variations"),
            (name: "1×TS", start: 0.8, end: 1.4, priority: TrendPriority.critical, 
             description: "Imbalance, misalignment, bent shaft"),
            (name: "2×TS", start: 1.4, end: 2.4, priority: TrendPriority.high, 
             description: "Mechanical looseness, angular misalignment"),
            (name: "3-8×TS", start: 2.4, end: 8.4, priority: TrendPriority.medium, 
             description: "Misalignment harmonics"),
            (name: "9-25×TS", start: 8.4, end: 25.4, priority: TrendPriority.high, 
             description: "Bearing defect frequencies"),
            (name: "25-75×TS", start: 25.4, end: 75.0, priority: TrendPriority.medium, 
             description: "High-frequency bearing impacts")
        ]
        
        for band in orderBands {
            if band.end <= fmaxOrders {
                let startHz = band.start * (result.rpm / 60.0)
                let endHz = band.end * (result.rpm / 60.0)
                let bandwidthHz = endHz - startHz
                let isResolvable = bandwidthHz >= (binWidthHz * 3) // Minimum 3 bins
                
                trends.append(TrendRecommendation(
                    name: band.name,
                    type: .orderBand(start: band.start, end: band.end),
                    priority: band.priority,
                    analysisType: .normal,
                    description: "Order-based frequency band analysis",
                    frequencyRangeHz: "\(String(format: "%.1f", startHz))-\(String(format: "%.1f", endHz)) Hz",
                    frequencyRangeOrders: "\(String(format: "%.1f", band.start))-\(String(format: "%.1f", band.end)) orders",
                    faultAssociation: band.description,
                    isWithinFmax: true,
                    isResolvable: isResolvable
                ))
            }
        }
        
        return trends
    }
    
    // MARK: - PeakVue AP Set Trends
    
    private static func generatePeakVueTrends(
        result: APSetDisplayResult,
        fmaxOrders: Double,
        fmaxHz: Double,
        binWidthHz: Double
    ) -> [TrendRecommendation] {
        
        var trends: [TrendRecommendation] = []
        
        // Primary PeakVue trends
        trends.append(TrendRecommendation(
            name: "PeakVue Maximum Peak",
            type: .waveform,
            priority: .critical,
            analysisType: .peakVue,
            description: "Maximum peak amplitude in stress wave analysis",
            frequencyRangeHz: nil,
            frequencyRangeOrders: nil,
            faultAssociation: "Primary bearing condition indicator",
            isWithinFmax: true,
            isResolvable: true
        ))
        
        trends.append(TrendRecommendation(
            name: "PeakVue RMS",
            type: .statistical,
            priority: .high,
            analysisType: .peakVue,
            description: "RMS of stress wave energy",
            frequencyRangeHz: "HP Filter-\(String(format: "%.1f", fmaxHz)) Hz",
            frequencyRangeOrders: nil,
            faultAssociation: "Overall stress wave energy level",
            isWithinFmax: true,
            isResolvable: true
        ))
        
        trends.append(TrendRecommendation(
            name: "PeakVue Crest Factor",
            type: .statistical,
            priority: .medium,
            analysisType: .peakVue,
            description: "Ratio of peak to RMS in stress wave analysis",
            frequencyRangeHz: nil,
            frequencyRangeOrders: nil,
            faultAssociation: "Impact severity in bearing analysis",
            isWithinFmax: true,
            isResolvable: true
        ))
        
        return trends
    }
    
    // MARK: - Equipment-Specific Trends
    
    private static func generateEquipmentSpecificTrends(
        equipmentType: String,
        vaneBladeCount: Int?,
        result: APSetDisplayResult,
        fmaxOrders: Double,
        fmaxHz: Double,
        binWidthHz: Double,
        analysisType: AnalysisType
    ) -> [TrendRecommendation] {
        
        var trends: [TrendRecommendation] = []
        
        switch equipmentType.lowercased() {
        case "fan", "blower":
            if let bladeCount = vaneBladeCount {
                let bpfOrders = Double(bladeCount)
                let bpfHz = bpfOrders * (result.rpm / 60.0)
                
                if (bpfOrders + 0.5) <= fmaxOrders {
                    let bandwidthHz = 1.0 * (result.rpm / 60.0) // ±0.5 orders
                    let isResolvable = bandwidthHz >= (binWidthHz * 2)
                    
                    trends.append(TrendRecommendation(
                        name: "Blade Pass Frequency",
                        type: .equipmentSpecific(frequency: bpfHz, name: "BPF"),
                        priority: .high,
                        analysisType: analysisType,
                        description: "Blade passage frequency monitoring",
                        frequencyRangeHz: "\(String(format: "%.1f", bpfHz - bandwidthHz/2))-\(String(format: "%.1f", bpfHz + bandwidthHz/2)) Hz",
                        frequencyRangeOrders: "\(String(format: "%.1f", bpfOrders - 0.5))-\(String(format: "%.1f", bpfOrders + 0.5)) orders",
                        faultAssociation: "Blade condition, aerodynamic issues, debris",
                        isWithinFmax: true,
                        isResolvable: isResolvable
                    ))
                }
            }
            
        case "pump":
            if let vaneCount = vaneBladeCount {
                let vpfOrders = Double(vaneCount)
                let vpfHz = vpfOrders * (result.rpm / 60.0)
                
                if (vpfOrders + 0.5) <= fmaxOrders {
                    let bandwidthHz = 1.0 * (result.rpm / 60.0) // ±0.5 orders
                    let isResolvable = bandwidthHz >= (binWidthHz * 2)
                    
                    trends.append(TrendRecommendation(
                        name: "Vane Pass Frequency",
                        type: .equipmentSpecific(frequency: vpfHz, name: "VPF"),
                        priority: .high,
                        analysisType: analysisType,
                        description: "Impeller vane passage frequency",
                        frequencyRangeHz: "\(String(format: "%.1f", vpfHz - bandwidthHz/2))-\(String(format: "%.1f", vpfHz + bandwidthHz/2)) Hz",
                        frequencyRangeOrders: "\(String(format: "%.1f", vpfOrders - 0.5))-\(String(format: "%.1f", vpfOrders + 0.5)) orders",
                        faultAssociation: "Impeller condition, cavitation, hydraulic forces",
                        isWithinFmax: true,
                        isResolvable: isResolvable
                    ))
                }
            }
            
        default:
            break
        }
        
        return trends
    }
    
    // MARK: - Bearing-Specific Trends
    
    private static func generateBearingSpecificTrends(
        result: APSetDisplayResult,
        fmaxOrders: Double,
        fmaxHz: Double,
        binWidthHz: Double,
        analysisType: AnalysisType
    ) -> [TrendRecommendation] {
        
        var trends: [TrendRecommendation] = []
        
        let bearingFrequencies = [
            (name: "BPFI", frequency: result.scaledBPFI, orders: result.orderBPFI, 
             description: "Ball Pass Frequency Inner race", association: "Inner race defects"),
            (name: "BPFO", frequency: result.scaledBPFO, orders: result.orderBPFO, 
             description: "Ball Pass Frequency Outer race", association: "Outer race defects"),
            (name: "BSF", frequency: result.scaledBSF, orders: result.orderBSF, 
             description: "Ball Spin Frequency", association: "Rolling element defects"),
            (name: "FTF", frequency: result.scaledFTF, orders: result.orderFTF, 
             description: "Fundamental Train Frequency", association: "Cage defects")
        ]
        
        for bearing in bearingFrequencies {
            if bearing.frequency > 0 {
                let centerOrders = bearing.orders
                let centerHz = bearing.frequency
                
                // Check if bearing frequency + harmonics fit within Fmax
                if (centerOrders + 0.5) <= fmaxOrders {
                    let bandwidthHz = 1.0 * (result.rpm / 60.0) // ±0.5 orders
                    let isResolvable = bandwidthHz >= (binWidthHz * 2)
                    
                    let priorityLevel: TrendPriority = (bearing.name == "BPFI" || bearing.name == "BPFO") ? .high : .medium
                    
                    trends.append(TrendRecommendation(
                        id: UUID(),
                        name: "\(bearing.name) Band",
                        type: .bearingBand(centerOrders: centerOrders, bandwidth: 1.0),
                        priority: priorityLevel,
                        analysisType: analysisType,
                        description: bearing.description,
                        frequencyRangeHz: "\(String(format: "%.1f", centerHz - bandwidthHz/2))-\(String(format: "%.1f", centerHz + bandwidthHz/2)) Hz",
                        frequencyRangeOrders: "\(String(format: "%.1f", centerOrders - 0.5))-\(String(format: "%.1f", centerOrders + 0.5)) orders",
                        faultAssociation: bearing.association,
                        isWithinFmax: true,
                        isResolvable: isResolvable
                    ))
                }
            }
        }
        
        return trends
    }
    
    // MARK: - Helper Methods
    
    private static func getFmaxInOrders(for result: APSetDisplayResult, analysisType: AnalysisType) -> Double {
        switch analysisType {
        case .normal:
            return result.fmax
        case .peakVue:
            // For PeakVue, use the actual PeakVue Fmax if available, otherwise use calculated
            if let pvFmax = result.peakVueCalculatedFmax {
                return pvFmax
            } else {
                return result.fmax // Fallback to normal Fmax
            }
        }
    }
    
    // MARK: - Shared Trend Display Utilities
    
    /// Generate formatted trend names for display (shared by views and PDF export)
    static func formatTrendsForDisplay(from result: APSetDisplayResult, analysisType: AnalysisType) -> [String] {
        let filteredTrends = result.trendRecommendations.filter { $0.analysisType == analysisType }
        
        if filteredTrends.isEmpty {
            // Fallback to basic trends if no recommendations available
            switch analysisType {
            case .normal:
                return ["Waveform Peak-Peak", "Overall RMS", "Crest Factor"]
            case .peakVue:
                return ["PeakVue Maximum Peak", "PeakVue RMS", "PeakVue Crest Factor"]
            }
        }
        
        return filteredTrends.map { trend in
            var trendName = trend.name
            
            // Add frequency range information for PDF/display
            if let frequencyRange = trend.frequencyRangeOrders ?? trend.frequencyRangeHz {
                trendName += " (\(frequencyRange))"
            }
            
            return trendName
        }
    }
    
    /// Generate formatted Normal trend names for display
    static func formatNormalTrendsForDisplay(from result: APSetDisplayResult) -> [String] {
        return formatTrendsForDisplay(from: result, analysisType: .normal)
    }
    
    /// Generate formatted PeakVue trend names for display  
    static func formatPeakVueTrendsForDisplay(from result: APSetDisplayResult) -> [String] {
        return formatTrendsForDisplay(from: result, analysisType: .peakVue)
    }
}

// MARK: - TrendPriority Extension

extension TrendPriority: Comparable {
    static func < (lhs: TrendPriority, rhs: TrendPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    var rawValue: Int {
        switch self {
        case .critical: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}