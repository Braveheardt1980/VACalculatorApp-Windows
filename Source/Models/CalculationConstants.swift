import Foundation

/// Centralized calculation constants - single source of truth for all multipliers
/// These values are used throughout the application and can be dynamically updated
/// when advanced settings are modified
class CalculationConstants: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = CalculationConstants()
    
    private init() {
        resetToDefaults()
    }
    
    // MARK: - Dynamic Constants
    
    /// Normal AP Set BPFI multiplier (default: 7.0)
    @Published var normalBPFIMultiplier: Double = 7.0
    
    /// Normal AP Set GMF multiplier (default: 3.5)
    @Published var normalGMFMultiplier: Double = 3.5
    
    /// Normal AP Set RPM fallback orders (default: 70.0)
    @Published var normalRPMFallbackOrders: Double = 70.0
    
    /// PeakVue BPFI multiplier (default: 4.0)
    @Published var peakVueBPFIMultiplier: Double = 4.0
    
    /// PeakVue RPM fallback orders (default: 30.0)
    @Published var peakVueRPMFallbackOrders: Double = 30.0
    
    // MARK: - Static Default Values
    
    private static let defaultNormalBPFIMultiplier: Double = 7.0
    private static let defaultNormalGMFMultiplier: Double = 3.5
    private static let defaultNormalRPMFallbackOrders: Double = 70.0
    private static let defaultPeakVueBPFIMultiplier: Double = 4.0
    private static let defaultPeakVueRPMFallbackOrders: Double = 30.0
    
    // MARK: - Other Constants (Static - These don't change)
    
    /// PeakVue GMF multiplier (always 1.0)
    static let peakVueGMFMultiplier: Double = 1.0
    
    /// LOR multiplier for calculations (always 15.0)
    static let lorMultiplier: Double = 15.0
    
    /// Minimum shaft revolutions requirement (always 15.0)
    static let minimumShaftRevolutions: Double = 15.0
    
    /// Standard Fmax options for recommendations
    static let standardFmaxOptions = [100.0, 200.0, 500.0, 1000.0, 2000.0, 5000.0, 10000.0, 20000.0]
    
    /// PeakVue Fmax options for recommendations
    static let peakVueFmaxOptions = [100.0, 200.0, 500.0, 1000.0, 2000.0, 5000.0]
    
    /// Maximum Fmax limits
    static let peakVueMaxFmaxHz: Double = 5000.0
    static let normalMaxFmaxHz: Double = 20000.0
    
    /// Standard LOR options
    static let standardLOROptions = [100, 200, 400, 800, 1600, 3200, 6400, 12800]
    
    /// Minimum LOR for PeakVue
    static let peakVueMinimumLOR = 1600
    
    /// Standard HP Filter frequencies
    static let standardHPFilterFrequencies = [500.0, 1000.0, 2000.0, 5000.0, 10000.0, 20000.0]
    
    /// Default HP Filter
    static let defaultHPFilterHz: Double = 1000.0
    
    // MARK: - Methods
    
    /// Reset all dynamic constants to their default values
    func resetToDefaults() {
        normalBPFIMultiplier = Self.defaultNormalBPFIMultiplier
        normalGMFMultiplier = Self.defaultNormalGMFMultiplier
        normalRPMFallbackOrders = Self.defaultNormalRPMFallbackOrders
        peakVueBPFIMultiplier = Self.defaultPeakVueBPFIMultiplier
        peakVueRPMFallbackOrders = Self.defaultPeakVueRPMFallbackOrders
    }
    
    /// Update constants from advanced settings
    func updateFromAdvancedSettings(_ settings: AdvancedCalculationSettings) {
        if settings.isAdvancedModeEnabled {
            normalBPFIMultiplier = settings.normalBPFIMultiplier
            normalGMFMultiplier = settings.normalGMFMultiplier
            normalRPMFallbackOrders = settings.normalRPMFallbackOrders
            peakVueBPFIMultiplier = settings.peakVueBPFIMultiplier
            peakVueRPMFallbackOrders = settings.peakVueRPMFallbackOrders
        } else {
            resetToDefaults()
        }
    }
    
    /// Check if any values differ from defaults
    var hasCustomValues: Bool {
        return normalBPFIMultiplier != Self.defaultNormalBPFIMultiplier ||
               normalGMFMultiplier != Self.defaultNormalGMFMultiplier ||
               normalRPMFallbackOrders != Self.defaultNormalRPMFallbackOrders ||
               peakVueBPFIMultiplier != Self.defaultPeakVueBPFIMultiplier ||
               peakVueRPMFallbackOrders != Self.defaultPeakVueRPMFallbackOrders
    }
    
    /// Get current values as AdvancedCalculationSettings
    func toAdvancedSettings(isEnabled: Bool = true) -> AdvancedCalculationSettings {
        return AdvancedCalculationSettings(
            isAdvancedModeEnabled: isEnabled,
            normalBPFIMultiplier: normalBPFIMultiplier,
            normalGMFMultiplier: normalGMFMultiplier,
            normalRPMFallbackOrders: normalRPMFallbackOrders,
            peakVueBPFIMultiplier: peakVueBPFIMultiplier,
            peakVueRPMFallbackOrders: peakVueRPMFallbackOrders
        )
    }
}