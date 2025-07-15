import XCTest
@testable import VACalculatorApp_Windows

class TrendRecommendationTests: XCTestCase {
    
    var trendService: TrendRecommendationService!
    var testResult: APSetDisplayResult!
    
    override func setUp() {
        super.setUp()
        trendService = TrendRecommendationService()
        
        // Create a test result for trend generation
        testResult = APSetDisplayResult(
            id: UUID(),
            rpm: 1800,
            bearingModel: "Test Bearing 6205",
            bearingType: "Deep Groove Ball",
            fmax: 70.0,
            lor: 800,
            shaftRevolutions: 26.67,
            isValid: true,
            validationMessages: [],
            calculatedFmax: 2100.0, // 70 * 1800 / 60
            sensorType: "Accelerometer",
            mountingMethod: "Stud",
            orderBPFI: 7.94,
            orderBPFO: 5.06,
            orderBSF: 2.357,
            orderFTF: 0.399,
            scaledBPFI: 238.2, // 7.94 * 1800 / 60
            scaledBPFO: 151.8, // 5.06 * 1800 / 60
            scaledBSF: 70.71,  // 2.357 * 1800 / 60
            scaledFTF: 11.97,  // 0.399 * 1800 / 60
            peakVueHPFilter: nil,
            peakVueCalculatedFmax: nil,
            trendRecommendations: []
        )
    }
    
    override func tearDown() {
        trendService = nil
        testResult = nil
        super.tearDown()
    }
    
    // MARK: - Normal Analysis Trend Tests
    
    func testNormalTrendGeneration() {
        let trends = trendService.generateTrendRecommendations(
            for: testResult,
            analysisType: .normal,
            rpm: 1800
        )
        
        XCTAssertFalse(trends.isEmpty, "Should generate trends for normal analysis")
        XCTAssertGreaterThan(trends.count, 5, "Should generate multiple trend recommendations")
        
        // Verify all trends are for normal analysis
        for trend in trends {
            XCTAssertEqual(trend.analysisType, .normal, "All trends should be for normal analysis")
            XCTAssertFalse(trend.name.isEmpty, "Trend should have a name")
            XCTAssertNotNil(trend.priority, "Trend should have a priority")
        }
    }
    
    func testNormalTrendCategories() {
        let trends = trendService.generateTrendRecommendations(
            for: testResult,
            analysisType: .normal,
            rpm: 1800
        )
        
        let trendNames = trends.map { $0.name }
        
        // Should include standard frequency bands
        XCTAssertTrue(trendNames.contains { $0.contains("Overall") }, "Should include overall trend")
        XCTAssertTrue(trendNames.contains { $0.contains("1×TS") }, "Should include 1×TS trend")
        XCTAssertTrue(trendNames.contains { $0.contains("2×TS") }, "Should include 2×TS trend")
        
        // Should include bearing fault frequencies
        XCTAssertTrue(trendNames.contains { $0.contains("BPFI") }, "Should include BPFI trend")
        XCTAssertTrue(trendNames.contains { $0.contains("BPFO") }, "Should include BPFO trend")
        
        // Should include frequency bands
        XCTAssertTrue(trendNames.contains { $0.contains("Sub-synchronous") }, "Should include sub-synchronous band")
        XCTAssertTrue(trendNames.contains { $0.contains("9-25×TS") }, "Should include mid-frequency band")
    }
    
    func testNormalTrendPriorities() {
        let trends = trendService.generateTrendRecommendations(
            for: testResult,
            analysisType: .normal,
            rpm: 1800
        )
        
        let criticalTrends = trends.filter { $0.priority == .critical }
        let highTrends = trends.filter { $0.priority == .high }
        let mediumTrends = trends.filter { $0.priority == .medium }
        
        XCTAssertFalse(criticalTrends.isEmpty, "Should have critical priority trends")
        XCTAssertFalse(highTrends.isEmpty, "Should have high priority trends")
        XCTAssertFalse(mediumTrends.isEmpty, "Should have medium priority trends")
        
        // Overall and 1×TS should be critical
        XCTAssertTrue(criticalTrends.contains { $0.name.contains("Overall") }, "Overall should be critical priority")
        XCTAssertTrue(criticalTrends.contains { $0.name.contains("1×TS") }, "1×TS should be critical priority")
    }
    
    // MARK: - PeakVue Analysis Trend Tests
    
    func testPeakVueTrendGeneration() {
        // Create PeakVue result
        var peakVueResult = testResult!
        peakVueResult.bearingModel = "Test Bearing 6205 (PeakVue)"
        peakVueResult.fmax = 30.5
        peakVueResult.lor = 400
        peakVueResult.peakVueHPFilter = 300.0
        peakVueResult.peakVueCalculatedFmax = 915.0 // 30.5 * 1800 / 60
        
        let trends = trendService.generateTrendRecommendations(
            for: peakVueResult,
            analysisType: .peakVue,
            rpm: 1800
        )
        
        XCTAssertFalse(trends.isEmpty, "Should generate trends for PeakVue analysis")
        
        // Verify all trends are for PeakVue analysis
        for trend in trends {
            XCTAssertEqual(trend.analysisType, .peakVue, "All trends should be for PeakVue analysis")
        }
    }
    
    func testPeakVueTrendCategories() {
        var peakVueResult = testResult!
        peakVueResult.bearingModel = "Test Bearing 6205 (PeakVue)"
        
        let trends = trendService.generateTrendRecommendations(
            for: peakVueResult,
            analysisType: .peakVue,
            rpm: 1800
        )
        
        let trendNames = trends.map { $0.name }
        
        // PeakVue should focus on bearing fault frequencies
        XCTAssertTrue(trendNames.contains { $0.contains("BPFI") }, "Should include BPFI trend")
        XCTAssertTrue(trendNames.contains { $0.contains("BPFO") }, "Should include BPFO trend")
        
        // Should include PeakVue-specific trends
        XCTAssertTrue(trendNames.contains { $0.contains("PeakVue") || $0.contains("Stress Wave") }, "Should include PeakVue-specific trends")
    }
    
    // MARK: - Frequency Range Tests
    
    func testTrendFrequencyRanges() {
        let trends = trendService.generateTrendRecommendations(
            for: testResult,
            analysisType: .normal,
            rpm: 1800
        )
        
        for trend in trends {
            // Should have either Hz or orders frequency range
            let hasHzRange = trend.frequencyRangeHz != nil && !trend.frequencyRangeHz!.isEmpty
            let hasOrderRange = trend.frequencyRangeOrders != nil && !trend.frequencyRangeOrders!.isEmpty
            
            XCTAssertTrue(hasHzRange || hasOrderRange, "Trend '\(trend.name)' should have frequency range")
            
            if let hzRange = trend.frequencyRangeHz {
                XCTAssertTrue(hzRange.contains("Hz"), "Hz range should contain 'Hz'")
            }
            
            if let orderRange = trend.frequencyRangeOrders {
                XCTAssertTrue(orderRange.contains("×") || orderRange.contains("orders"), "Order range should contain '×' or 'orders'")
            }
        }
    }
    
    func testSpecificFrequencyRanges() {
        let trends = trendService.generateTrendRecommendations(
            for: testResult,
            analysisType: .normal,
            rpm: 1800
        )
        
        // Test specific frequency ranges for known trends
        if let overallTrend = trends.first(where: { $0.name.contains("Overall") }) {
            XCTAssertNotNil(overallTrend.frequencyRangeHz, "Overall trend should have Hz range")
            if let range = overallTrend.frequencyRangeHz {
                XCTAssertTrue(range.contains("10") && range.contains("1000"), "Overall should cover broad frequency range")
            }
        }
        
        if let bpfiTrend = trends.first(where: { $0.name.contains("BPFI") }) {
            XCTAssertNotNil(bpfiTrend.frequencyRangeHz, "BPFI trend should have Hz range")
            if let range = bpfiTrend.frequencyRangeHz {
                XCTAssertTrue(range.contains("238"), "BPFI range should include calculated frequency")
            }
        }
    }
    
    // MARK: - RPM Dependency Tests
    
    func testDifferentRPMValues() {
        let rpms: [Double] = [900, 1800, 3600]
        
        for rpm in rpms {
            var rpmResult = testResult!
            rpmResult.rpm = rpm
            
            // Update calculated values for different RPM
            rpmResult.scaledBPFI = testResult.orderBPFI * rpm / 60.0
            rpmResult.scaledBPFO = testResult.orderBPFO * rpm / 60.0
            rpmResult.calculatedFmax = testResult.fmax * rpm / 60.0
            
            let trends = trendService.generateTrendRecommendations(
                for: rpmResult,
                analysisType: .normal,
                rpm: rpm
            )
            
            XCTAssertFalse(trends.isEmpty, "Should generate trends for \(rpm) RPM")
            
            // Verify frequency ranges scale with RPM
            if let bpfiTrend = trends.first(where: { $0.name.contains("BPFI") }) {
                if let range = bpfiTrend.frequencyRangeHz {
                    let expectedBPFI = testResult.orderBPFI * rpm / 60.0
                    XCTAssertTrue(range.contains(String(format: "%.0f", expectedBPFI)), "BPFI frequency should scale with RPM")
                }
            }
        }
    }
    
    // MARK: - Equipment Type Variations
    
    func testDifferentEquipmentTypes() {
        let equipmentTypes = ["Motor", "Pump", "Fan", "Compressor"]
        
        for equipment in equipmentTypes {
            var equipmentResult = testResult!
            equipmentResult.bearingModel = "Generic \(equipment) Bearing"
            
            let trends = trendService.generateTrendRecommendations(
                for: equipmentResult,
                analysisType: .normal,
                rpm: 1800
            )
            
            XCTAssertFalse(trends.isEmpty, "Should generate trends for \(equipment)")
            
            // All equipment should have basic trends
            let trendNames = trends.map { $0.name }
            XCTAssertTrue(trendNames.contains { $0.contains("Overall") }, "\(equipment) should have overall trend")
            XCTAssertTrue(trendNames.contains { $0.contains("1×TS") }, "\(equipment) should have 1×TS trend")
        }
    }
    
    // MARK: - Generic vs Specific Bearing Tests
    
    func testGenericBearingTrends() {
        var genericResult = testResult!
        genericResult.bearingModel = "Generic Motor Bearing"
        genericResult.orderBPFI = 0
        genericResult.orderBPFO = 0
        genericResult.scaledBPFI = 0
        genericResult.scaledBPFO = 0
        
        let trends = trendService.generateTrendRecommendations(
            for: genericResult,
            analysisType: .normal,
            rpm: 1800
        )
        
        XCTAssertFalse(trends.isEmpty, "Should generate trends for generic bearing")
        
        // Should not include specific bearing fault frequencies
        let trendNames = trends.map { $0.name }
        XCTAssertFalse(trendNames.contains { $0.contains("BPFI") && $0.contains("238") }, "Should not have specific BPFI frequency for generic bearing")
        
        // Should include general categories
        XCTAssertTrue(trendNames.contains { $0.contains("Overall") }, "Generic bearing should have overall trend")
        XCTAssertTrue(trendNames.contains { $0.contains("Bearing Frequency Band") }, "Generic bearing should have bearing frequency band")
    }
    
    func testSpecificBearingTrends() {
        // testResult already has specific bearing frequencies
        let trends = trendService.generateTrendRecommendations(
            for: testResult,
            analysisType: .normal,
            rpm: 1800
        )
        
        let trendNames = trends.map { $0.name }
        
        // Should include specific bearing fault frequencies
        XCTAssertTrue(trendNames.contains { $0.contains("BPFI") }, "Specific bearing should have BPFI trend")
        XCTAssertTrue(trendNames.contains { $0.contains("BPFO") }, "Specific bearing should have BPFO trend")
        XCTAssertTrue(trendNames.contains { $0.contains("BSF") }, "Specific bearing should have BSF trend")
        XCTAssertTrue(trendNames.contains { $0.contains("FTF") }, "Specific bearing should have FTF trend")
    }
    
    // MARK: - Trend Formatting Tests
    
    func testTrendNameFormatting() {
        let trends = trendService.generateTrendRecommendations(
            for: testResult,
            analysisType: .normal,
            rpm: 1800
        )
        
        for trend in trends {
            XCTAssertFalse(trend.name.isEmpty, "Trend name should not be empty")
            XCTAssertFalse(trend.name.hasPrefix(" "), "Trend name should not start with space")
            XCTAssertFalse(trend.name.hasSuffix(" "), "Trend name should not end with space")
            XCTAssertTrue(trend.name.count < 100, "Trend name should be reasonable length")
        }
    }
    
    func testFrequencyRangeFormatting() {
        let trends = trendService.generateTrendRecommendations(
            for: testResult,
            analysisType: .normal,
            rpm: 1800
        )
        
        for trend in trends {
            if let hzRange = trend.frequencyRangeHz {
                XCTAssertTrue(hzRange.contains("Hz"), "Hz range should contain 'Hz'")
                XCTAssertFalse(hzRange.hasPrefix(" "), "Hz range should not start with space")
                XCTAssertFalse(hzRange.hasSuffix(" "), "Hz range should not end with space")
            }
            
            if let orderRange = trend.frequencyRangeOrders {
                XCTAssertTrue(orderRange.contains("×") || orderRange.contains("orders"), "Order range should contain multiplier")
                XCTAssertFalse(orderRange.hasPrefix(" "), "Order range should not start with space")
                XCTAssertFalse(orderRange.hasSuffix(" "), "Order range should not end with space")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testTrendGenerationPerformance() {
        measure {
            for _ in 0..<100 {
                let _ = trendService.generateTrendRecommendations(
                    for: testResult,
                    analysisType: .normal,
                    rpm: 1800
                )
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testZeroFrequencyHandling() {
        var zeroResult = testResult!
        zeroResult.scaledBPFI = 0
        zeroResult.scaledBPFO = 0
        zeroResult.scaledBSF = 0
        zeroResult.scaledFTF = 0
        
        let trends = trendService.generateTrendRecommendations(
            for: zeroResult,
            analysisType: .normal,
            rpm: 1800
        )
        
        XCTAssertFalse(trends.isEmpty, "Should still generate trends with zero frequencies")
        
        // Should not include trends with zero frequencies
        for trend in trends {
            if let hzRange = trend.frequencyRangeHz {
                XCTAssertFalse(hzRange.contains("0 Hz"), "Should not include zero frequency trends")
            }
        }
    }
    
    func testHighFrequencyHandling() {
        var highFreqResult = testResult!
        highFreqResult.rpm = 10000 // Very high RPM
        highFreqResult.calculatedFmax = testResult.fmax * 10000 / 60.0
        highFreqResult.scaledBPFI = testResult.orderBPFI * 10000 / 60.0
        
        let trends = trendService.generateTrendRecommendations(
            for: highFreqResult,
            analysisType: .normal,
            rpm: 10000
        )
        
        XCTAssertFalse(trends.isEmpty, "Should handle high frequency scenarios")
        
        // Verify frequencies are calculated correctly for high RPM
        if let bpfiTrend = trends.first(where: { $0.name.contains("BPFI") }) {
            if let range = bpfiTrend.frequencyRangeHz {
                let expectedBPFI = testResult.orderBPFI * 10000 / 60.0
                XCTAssertTrue(range.contains(String(format: "%.0f", expectedBPFI)), "Should calculate high frequencies correctly")
            }
        }
    }
    
    // MARK: - Integration with Display Formatting
    
    func testDisplayFormattingIntegration() {
        let trends = trendService.generateTrendRecommendations(
            for: testResult,
            analysisType: .normal,
            rpm: 1800
        )
        
        // Test the display formatting functions
        let normalTrends = TrendRecommendationService.formatNormalTrendsForDisplay(trends)
        XCTAssertFalse(normalTrends.isEmpty, "Should format normal trends for display")
        
        for displayTrend in normalTrends {
            XCTAssertFalse(displayTrend.isEmpty, "Display trend should not be empty")
            XCTAssertTrue(displayTrend.count < 200, "Display trend should be reasonable length")
        }
    }
}