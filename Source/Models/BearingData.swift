import Foundation

// MARK: - BearingData Model
// Core bearing model that represents both generic and specific bearings

struct BearingData: Identifiable, Codable {
    let id: String
    let designation: String  // Display name like "6205" or "Generic Motor Bearing"
    let bearingType: String  // Type like "Deep Groove Ball", "Generic", etc.
    let isGeneric: Bool     // Whether this is a generic bearing (no specific fault frequencies)
    
    // Fault frequency coefficients (orders) - nil for generic bearings
    let bpfi: Double?  // Ball Pass Frequency Inner race
    let bpfo: Double?  // Ball Pass Frequency Outer race  
    let bsf: Double?   // Ball Spin Frequency
    let ftf: Double?   // Fundamental Train Frequency / Cage frequency
    
    // Additional bearing information (optional)
    let ballRollerCount: Int?
    let contactAngle: Double?
    let pitchDiameter: Double?
    let ballDiameter: Double?
    
    // Computed properties for compatibility
    var model: String { designation }
    var name: String { designation }
    
    // MARK: - Initializers
    
    /// Initialize with basic fault frequency data (most common case)
    init(id: String, designation: String, bearingType: String, isGeneric: Bool, 
         bpfi: Double?, bpfo: Double?, bsf: Double?, ftf: Double?) {
        self.id = id
        self.designation = designation
        self.bearingType = bearingType
        self.isGeneric = isGeneric
        self.bpfi = bpfi
        self.bpfo = bpfo
        self.bsf = bsf
        self.ftf = ftf
        self.ballRollerCount = nil
        self.contactAngle = nil
        self.pitchDiameter = nil
        self.ballDiameter = nil
    }
    
    /// Initialize with full bearing geometry data
    init(id: String, designation: String, bearingType: String, isGeneric: Bool,
         bpfi: Double?, bpfo: Double?, bsf: Double?, ftf: Double?,
         ballRollerCount: Int?, contactAngle: Double?, 
         pitchDiameter: Double?, ballDiameter: Double?) {
        self.id = id
        self.designation = designation
        self.bearingType = bearingType
        self.isGeneric = isGeneric
        self.bpfi = bpfi
        self.bpfo = bpfo
        self.bsf = bsf
        self.ftf = ftf
        self.ballRollerCount = ballRollerCount
        self.contactAngle = contactAngle
        self.pitchDiameter = pitchDiameter
        self.ballDiameter = ballDiameter
    }
    
    // MARK: - Helper Methods
    
    /// Check if bearing has valid fault frequency data
    var hasFaultFrequencies: Bool {
        return !isGeneric && bpfi != nil && bpfo != nil && bsf != nil && ftf != nil
    }
    
    /// Get all fault frequencies as a tuple
    var faultFrequencies: (bpfi: Double, bpfo: Double, bsf: Double, ftf: Double)? {
        guard let bpfi = bpfi, let bpfo = bpfo, let bsf = bsf, let ftf = ftf else {
            return nil
        }
        return (bpfi: bpfi, bpfo: bpfo, bsf: bsf, ftf: ftf)
    }
    
    /// Scale fault frequencies to Hz for given RPM
    func scaledFrequencies(for rpm: Double) -> (bpfi: Double, bpfo: Double, bsf: Double, ftf: Double)? {
        guard let frequencies = faultFrequencies else { return nil }
        let rpmInHz = rpm / 60.0
        return (
            bpfi: frequencies.bpfi * rpmInHz,
            bpfo: frequencies.bpfo * rpmInHz,
            bsf: frequencies.bsf * rpmInHz,
            ftf: frequencies.ftf * rpmInHz
        )
    }
    
    // Compatibility methods removed for simplified Windows build
}

// MARK: - Generic Bearing Factory Methods
extension BearingData {
    /// Create a generic motor bearing for fallback calculations
    static func genericMotorBearing() -> BearingData {
        return BearingData(
            id: "generic-motor",
            designation: "Generic Motor Bearing",
            bearingType: "Generic",
            isGeneric: true,
            bpfi: nil,
            bpfo: nil,
            bsf: nil,
            ftf: nil
        )
    }
    
    /// Create a generic pump bearing for fallback calculations
    static func genericPumpBearing() -> BearingData {
        return BearingData(
            id: "generic-pump",
            designation: "Generic Pump Bearing",
            bearingType: "Generic",
            isGeneric: true,
            bpfi: nil,
            bpfo: nil,
            bsf: nil,
            ftf: nil
        )
    }
    
    /// Create a generic fan bearing for fallback calculations
    static func genericFanBearing() -> BearingData {
        return BearingData(
            id: "generic-fan",
            designation: "Generic Fan Bearing",
            bearingType: "Generic",
            isGeneric: true,
            bpfi: nil,
            bpfo: nil,
            bsf: nil,
            ftf: nil
        )
    }
    
    /// Create a generic gearbox bearing for fallback calculations
    static func genericGearboxBearing() -> BearingData {
        return BearingData(
            id: "generic-gearbox",
            designation: "Generic Gearbox Bearing",
            bearingType: "Generic",
            isGeneric: true,
            bpfi: nil,
            bpfo: nil,
            bsf: nil,
            ftf: nil
        )
    }
}

// MARK: - BearingInfo Compatibility
// The existing BearingInfo struct should be maintained for JSON parsing compatibility
// BearingData provides a more comprehensive model for internal calculations