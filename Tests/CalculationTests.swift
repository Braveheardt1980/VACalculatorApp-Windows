import XCTest
@testable import VACalculatorApp_Windows

class CalculationTests: XCTestCase {
    
    var calculationService: UnifiedCalculationService!
    var formulaService: FormulaService!
    var filterService: FilterCalculationService!
    
    override func setUp() {
        super.setUp()
        calculationService = UnifiedCalculationService()
        formulaService = FormulaService()
        filterService = FilterCalculationService()
    }
    
    override func tearDown() {
        calculationService = nil
        formulaService = nil
        filterService = nil
        super.tearDown()
    }
    
    // MARK: - Generic Bearing Tests (Motor)
    
    func testGenericMotorNormalCalculation() {
        // Test case: 1800 RPM Motor, Normal Analysis
        let genericBearing = BearingData.createGenericMotorBearing()
        
        let result = calculationService.calculateUnifiedShaftBearingResults(
            bearingData: genericBearing,
            rpm: 1800,
            analysisType: .normal,
            sensorType: "Accelerometer",
            mountingMethod: "Stud"
        )
        
        XCTAssertNotNil(result, "Calculation should return a result")
        
        guard let result = result else { return }
        
        // Verify Normal analysis parameters
        XCTAssertEqual(result.fmax, 70.0, accuracy: 0.1, "Fmax should be 70 orders for generic motor")
        XCTAssertEqual(result.lor, 800, "LOR should be 800 for generic motor")
        XCTAssertEqual(result.rpm, 1800, accuracy: 0.1, "RPM should match input")
        XCTAssertTrue(result.isValid, "Result should be valid")
        XCTAssertEqual(result.bearingModel, "Generic Motor Bearing", "Bearing model should match")
        
        // Verify calculated values
        let expectedCalculatedFmax = 70.0 * 1800 / 60.0 // 2100 Hz
        XCTAssertEqual(result.calculatedFmax ?? 0, expectedCalculatedFmax, accuracy: 1.0, "Calculated Fmax should be correct")
        
        // Verify shaft revolutions
        let expectedShaftRevolutions = formulaService.calculateShaftRevolutions(lor: 800, rpm: 1800)
        XCTAssertEqual(result.shaftRevolutions, expectedShaftRevolutions, accuracy: 0.1, "Shaft revolutions should be correct")
    }
    
    func testGenericMotorPeakVueCalculation() {
        // Test case: 1800 RPM Motor, PeakVue Analysis
        let genericBearing = BearingData.createGenericMotorBearing()
        
        let result = calculationService.calculateUnifiedShaftBearingResults(
            bearingData: genericBearing,
            rpm: 1800,
            analysisType: .peakVue,
            sensorType: "Accelerometer",
            mountingMethod: "Stud"
        )
        
        XCTAssertNotNil(result, "PeakVue calculation should return a result")
        
        guard let result = result else { return }
        
        // Verify PeakVue analysis parameters
        XCTAssertEqual(result.fmax, 30.5, accuracy: 0.1, "PeakVue Fmax should be 30.5 orders for generic motor")
        XCTAssertEqual(result.lor, 400, "PeakVue LOR should be 400 for generic motor")
        XCTAssertTrue(result.bearingModel.contains("PeakVue"), "Bearing model should indicate PeakVue")
        
        // Verify HP Filter
        let expectedHPFilter = filterService.calculatePeakVueHPFilter(rpm: 1800)
        XCTAssertEqual(result.peakVueHPFilter ?? 0, expectedHPFilter, accuracy: 1.0, "HP Filter should be correct")
        
        // Verify PeakVue calculated Fmax
        let expectedPeakVueCalculatedFmax = 30.5 * 1800 / 60.0 // 915 Hz
        XCTAssertEqual(result.peakVueCalculatedFmax ?? 0, expectedPeakVueCalculatedFmax, accuracy: 1.0, "PeakVue calculated Fmax should be correct")
    }
    
    // MARK: - Specific Bearing Tests
    
    func testSpecificBearingCalculation() {
        // Test case: Specific bearing with known characteristics
        let specificBearing = BearingData(
            id: "test-6205",
            designation: "6205",
            bearingType: "Deep Groove Ball",
            isGeneric: false,
            bpfi: 7.94,
            bpfo: 5.06,
            bsf: 2.357,
            ftf: 0.399
        )
        
        let result = calculationService.calculateUnifiedShaftBearingResults(
            bearingData: specificBearing,
            rpm: 1800,
            analysisType: .normal,
            sensorType: "Accelerometer",
            mountingMethod: "Stud"
        )
        
        XCTAssertNotNil(result, "Specific bearing calculation should return a result")
        
        guard let result = result else { return }
        
        // Verify bearing frequencies are calculated
        let expectedBPFI = 7.94 * 1800 / 60.0 // 238.2 Hz
        let expectedBPFO = 5.06 * 1800 / 60.0 // 151.8 Hz
        let expectedBSF = 2.357 * 1800 / 60.0  // 70.71 Hz
        let expectedFTF = 0.399 * 1800 / 60.0  // 11.97 Hz
        
        XCTAssertEqual(result.scaledBPFI, expectedBPFI, accuracy: 1.0, "BPFI frequency should be correct")
        XCTAssertEqual(result.scaledBPFO, expectedBPFO, accuracy: 1.0, "BPFO frequency should be correct")
        XCTAssertEqual(result.scaledBSF, expectedBSF, accuracy: 1.0, "BSF frequency should be correct")
        XCTAssertEqual(result.scaledFTF, expectedFTF, accuracy: 1.0, "FTF frequency should be correct")
        
        // Verify order values are preserved
        XCTAssertEqual(result.orderBPFI, 7.94, accuracy: 0.01, "BPFI order should match bearing data")
        XCTAssertEqual(result.orderBPFO, 5.06, accuracy: 0.01, "BPFO order should match bearing data")
    }
    
    // MARK: - Formula Service Tests
    
    func testLORCalculation() {
        // Test various LOR calculations
        let lor1 = formulaService.calculateLOR(fmax: 70.0, rpm: 1800)
        XCTAssertEqual(lor1, 800, "LOR for 70 orders at 1800 RPM should be 800")
        
        let lor2 = formulaService.calculateLOR(fmax: 30.5, rpm: 1800)
        XCTAssertEqual(lor2, 400, "LOR for 30.5 orders at 1800 RPM should be 400")
        
        let lor3 = formulaService.calculateLOR(fmax: 100.0, rpm: 3600)
        let expectedLor3 = Int(100.0 * 3600 / 60.0 / 2.56) // Standard calculation
        XCTAssertEqual(lor3, expectedLor3, "LOR calculation should follow standard formula")
    }
    
    func testShaftRevolutionsCalculation() {
        // Test shaft revolutions calculation
        let revolutions1 = formulaService.calculateShaftRevolutions(lor: 800, rpm: 1800)
        let expected1 = Double(800) / (1800.0 / 60.0) // 26.67 seconds
        XCTAssertEqual(revolutions1, expected1, accuracy: 0.1, "Shaft revolutions should be correct")
        
        let revolutions2 = formulaService.calculateShaftRevolutions(lor: 400, rpm: 3600)
        let expected2 = Double(400) / (3600.0 / 60.0) // 6.67 seconds
        XCTAssertEqual(revolutions2, expected2, accuracy: 0.1, "Shaft revolutions should be correct")
    }
    
    // MARK: - Filter Service Tests
    
    func testPeakVueHPFilterCalculation() {
        // Test HP filter calculations for various RPMs
        let hpFilter1800 = filterService.calculatePeakVueHPFilter(rpm: 1800)
        XCTAssertGreaterThan(hpFilter1800, 0, "HP Filter should be positive")
        
        let hpFilter3600 = filterService.calculatePeakVueHPFilter(rpm: 3600)
        XCTAssertGreaterThan(hpFilter3600, hpFilter1800, "Higher RPM should have higher HP filter")
        
        // Test specific expected values based on original implementation
        let expectedFilter1800 = 1800.0 / 60.0 * 10.0 // Example calculation
        XCTAssertEqual(hpFilter1800, expectedFilter1800, accuracy: 50.0, "HP Filter should be in expected range")
    }
    
    // MARK: - Edge Cases and Validation
    
    func testZeroRPMHandling() {
        let genericBearing = BearingData.createGenericMotorBearing()
        
        let result = calculationService.calculateUnifiedShaftBearingResults(
            bearingData: genericBearing,
            rpm: 0,
            analysisType: .normal,
            sensorType: "Accelerometer",
            mountingMethod: "Stud"
        )
        
        // Should handle zero RPM gracefully
        XCTAssertNotNil(result, "Should handle zero RPM")
        if let result = result {
            XCTAssertFalse(result.isValid, "Zero RPM should be marked as invalid")
        }
    }
    
    func testHighRPMHandling() {
        let genericBearing = BearingData.createGenericMotorBearing()
        
        let result = calculationService.calculateUnifiedShaftBearingResults(
            bearingData: genericBearing,
            rpm: 50000, // Very high RPM
            analysisType: .normal,
            sensorType: "Accelerometer",
            mountingMethod: "Stud"
        )
        
        XCTAssertNotNil(result, "Should handle high RPM")
        if let result = result {
            // High RPM might be valid or invalid depending on implementation
            XCTAssertGreaterThan(result.calculatedFmax ?? 0, 0, "Calculated Fmax should be positive for high RPM")
        }
    }
    
    // MARK: - Multiple Equipment Types
    
    func testPumpEquipmentCalculation() {
        let pumpBearing = BearingData.createGenericPumpBearing()
        
        let result = calculationService.calculateUnifiedShaftBearingResults(
            bearingData: pumpBearing,
            rpm: 1800,
            analysisType: .normal,
            sensorType: "Accelerometer",
            mountingMethod: "Stud"
        )
        
        XCTAssertNotNil(result, "Pump calculation should work")
        if let result = result {
            XCTAssertTrue(result.isValid, "Pump calculation should be valid")
            XCTAssertEqual(result.rpm, 1800, accuracy: 0.1, "RPM should match")
        }
    }
    
    func testFanEquipmentCalculation() {
        let fanBearing = BearingData.createGenericFanBearing()
        
        let result = calculationService.calculateUnifiedShaftBearingResults(
            bearingData: fanBearing,
            rpm: 900, // Lower RPM typical for fans
            analysisType: .normal,
            sensorType: "Accelerometer",
            mountingMethod: "Stud"
        )
        
        XCTAssertNotNil(result, "Fan calculation should work")
        if let result = result {
            XCTAssertTrue(result.isValid, "Fan calculation should be valid")
            XCTAssertEqual(result.rpm, 900, accuracy: 0.1, "RPM should match")
        }
    }
    
    // MARK: - Sensor and Mounting Method Validation
    
    func testDifferentSensorTypes() {
        let genericBearing = BearingData.createGenericMotorBearing()
        
        let sensorTypes = ["Accelerometer", "Velocity", "Displacement"]
        
        for sensorType in sensorTypes {
            let result = calculationService.calculateUnifiedShaftBearingResults(
                bearingData: genericBearing,
                rpm: 1800,
                analysisType: .normal,
                sensorType: sensorType,
                mountingMethod: "Stud"
            )
            
            XCTAssertNotNil(result, "Calculation should work for \(sensorType)")
            if let result = result {
                XCTAssertEqual(result.sensorType, sensorType, "Sensor type should be preserved")
            }
        }
    }
    
    func testDifferentMountingMethods() {
        let genericBearing = BearingData.createGenericMotorBearing()
        
        let mountingMethods = ["Stud", "Magnet", "Handheld", "Triaxial"]
        
        for mountingMethod in mountingMethods {
            let result = calculationService.calculateUnifiedShaftBearingResults(
                bearingData: genericBearing,
                rpm: 1800,
                analysisType: .normal,
                sensorType: "Accelerometer",
                mountingMethod: mountingMethod
            )
            
            XCTAssertNotNil(result, "Calculation should work for \(mountingMethod)")
            if let result = result {
                XCTAssertEqual(result.mountingMethod, mountingMethod, "Mounting method should be preserved")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testCalculationPerformance() {
        let genericBearing = BearingData.createGenericMotorBearing()
        
        measure {
            for _ in 0..<100 {
                let _ = calculationService.calculateUnifiedShaftBearingResults(
                    bearingData: genericBearing,
                    rpm: 1800,
                    analysisType: .normal,
                    sensorType: "Accelerometer",
                    mountingMethod: "Stud"
                )
            }
        }
    }
}

// MARK: - Test Helper Extensions

extension BearingData {
    static func createGenericMotorBearing() -> BearingData {
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
    
    static func createGenericPumpBearing() -> BearingData {
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
    
    static func createGenericFanBearing() -> BearingData {
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
}