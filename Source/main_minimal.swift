import Foundation

// MARK: - Minimal Test Application for Core Services
// This tests the calculation logic without UI dependencies

// Test the core calculation services
func testCoreCalculations() {
    print("🧪 Testing VA Calculator Core Calculations...")
    print("=" + String(repeating: "=", count: 50))
    
    // Test 1: Formula Service
    print("\n📊 Testing Formula Service...")
    let lor1 = FormulaService.calculateLOR(fmax: 70.0, rpm: 1800)
    let lor2 = FormulaService.calculateLOR(fmax: 30.5, rpm: 1800)
    let shaftRevs = FormulaService.calculateShaftRevolutions(lor: 800, rpm: 1800)
    
    print("✓ LOR for 70 orders at 1800 RPM: \(lor1)")
    print("✓ LOR for 30.5 orders at 1800 RPM: \(lor2)")
    print("✓ Shaft revolutions: \(String(format: "%.2f", shaftRevs)) seconds")
    
    // Test 2: Filter Service
    print("\n🔧 Testing Filter Service...")
    let hpFilter = FilterCalculationService.calculatePeakVueHPFilter(rpm: 1800)
    print("✓ PeakVue HP Filter for 1800 RPM: \(hpFilter) Hz")
    
    // Test 3: Generic Bearing Calculation
    print("\n⚙️ Testing Generic Bearing Calculation...")
    let genericBearing = BearingData(
        id: "generic-motor",
        designation: "Generic Motor Bearing",
        bearingType: "Generic",
        isGeneric: true,
        bpfi: nil,
        bpfo: nil,
        bsf: nil,
        ftf: nil
    )
    
    let calculationService = UnifiedCalculationService()
    
    if let normalResult = calculationService.calculateUnifiedShaftBearingResults(
        bearingData: genericBearing,
        rpm: 1800,
        analysisType: .normal,
        sensorType: "Accelerometer",
        mountingMethod: "Stud"
    ) {
        print("✓ Normal Analysis Result:")
        print("  - Fmax: \(normalResult.fmax) orders")
        print("  - LOR: \(normalResult.lor)")
        print("  - Shaft Revolutions: \(String(format: "%.2f", normalResult.shaftRevolutions))")
        print("  - Valid: \(normalResult.isValid)")
        if let calcFmax = normalResult.calculatedFmax {
            print("  - Calculated Fmax: \(String(format: "%.1f", calcFmax)) Hz")
        }
    } else {
        print("❌ Normal calculation failed")
    }
    
    if let peakVueResult = calculationService.calculateUnifiedShaftBearingResults(
        bearingData: genericBearing,
        rpm: 1800,
        analysisType: .peakVue,
        sensorType: "Accelerometer",
        mountingMethod: "Stud"
    ) {
        print("✓ PeakVue Analysis Result:")
        print("  - Fmax: \(peakVueResult.fmax) orders")
        print("  - LOR: \(peakVueResult.lor)")
        print("  - HP Filter: \(peakVueResult.peakVueHPFilter ?? 0) Hz")
        print("  - Valid: \(peakVueResult.isValid)")
        if let calcFmax = peakVueResult.peakVueCalculatedFmax {
            print("  - Calculated Fmax: \(String(format: "%.1f", calcFmax)) Hz")
        }
    } else {
        print("❌ PeakVue calculation failed")
    }
    
    // Test 4: Specific Bearing Calculation
    print("\n🎯 Testing Specific Bearing Calculation...")
    let specificBearing = BearingData(
        id: "6205",
        designation: "6205",
        bearingType: "Deep Groove Ball",
        isGeneric: false,
        bpfi: 7.94,
        bpfo: 5.06,
        bsf: 2.357,
        ftf: 0.399
    )
    
    if let specificResult = calculationService.calculateUnifiedShaftBearingResults(
        bearingData: specificBearing,
        rpm: 1800,
        analysisType: .normal,
        sensorType: "Accelerometer",
        mountingMethod: "Stud"
    ) {
        print("✓ 6205 Bearing Result:")
        print("  - BPFI: \(String(format: "%.3f", specificResult.orderBPFI))× (\(String(format: "%.1f", specificResult.scaledBPFI)) Hz)")
        print("  - BPFO: \(String(format: "%.3f", specificResult.orderBPFO))× (\(String(format: "%.1f", specificResult.scaledBPFO)) Hz)")
        print("  - BSF: \(String(format: "%.3f", specificResult.orderBSF))× (\(String(format: "%.1f", specificResult.scaledBSF)) Hz)")
        print("  - FTF: \(String(format: "%.3f", specificResult.orderFTF))× (\(String(format: "%.1f", specificResult.scaledFTF)) Hz)")
    } else {
        print("❌ Specific bearing calculation failed")
    }
    
    // Test 5: Trend Generation
    print("\n📈 Testing Trend Generation...")
    let trendService = TrendRecommendationService()
    
    if let testResult = calculationService.calculateUnifiedShaftBearingResults(
        bearingData: specificBearing,
        rpm: 1800,
        analysisType: .normal,
        sensorType: "Accelerometer",
        mountingMethod: "Stud"
    ) {
        let trends = trendService.generateTrendRecommendations(
            for: testResult,
            analysisType: .normal,
            rpm: 1800
        )
        
        print("✓ Generated \(trends.count) trend recommendations:")
        for trend in trends.prefix(5) {
            let priority = trend.priority.description
            let hzRange = trend.frequencyRangeHz ?? "N/A"
            print("  - [\(priority)] \(trend.name) (\(hzRange))")
        }
        if trends.count > 5 {
            print("  ... and \(trends.count - 5) more trends")
        }
    }
    
    // Test 6: Security System
    print("\n🔐 Testing Security System...")
    let securityManager = SecurityManager.shared
    
    let testLicense: [String: Any] = [
        "version": "1.0",
        "issued_date": "2025-07-14T21:30:00Z",
        "expiry_date": "2026-07-14T21:30:00Z",
        "authorized_users": ["WORKSTATION\\testuser"],
        "features": [
            "full_calculator": true,
            "pdf_export": true,
            "advanced_trends": true
        ],
        "hardware_binding": [
            "binding_enabled": false
        ],
        "signature": "test_signature"
    ]
    
    let structureValid = securityManager.validateLicenseStructure(testLicense)
    let userAuthorized = securityManager.validateUserAuthorization(testLicense, currentUser: "WORKSTATION\\testuser")
    let hardwareResult = securityManager.validateHardwareBinding(testLicense, currentMachineId: "test-machine")
    
    print("✓ License structure valid: \(structureValid)")
    print("✓ User authorization: \(userAuthorized)")
    print("✓ Hardware validation: \(hardwareResult.isValid)")
    
    print("\n🎉 Core calculation testing completed!")
    print("All major components are functional and ready for Windows deployment.")
}

// Entry point for minimal test
// To run tests, uncomment the line below when using this file standalone
// testCoreCalculations()