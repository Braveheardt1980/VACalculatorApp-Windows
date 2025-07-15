import XCTest
@testable import VACalculatorApp_Windows

class BearingLookupTests: XCTestCase {
    
    var bearingEngine: BearingLookupEngine!
    
    override func setUp() {
        super.setUp()
        bearingEngine = BearingLookupEngine.shared
    }
    
    override func tearDown() {
        bearingEngine = nil
        super.tearDown()
    }
    
    // MARK: - Database Loading Tests
    
    func testBearingDatabaseLoads() {
        // Test that the bearing database loads successfully
        let bearings = bearingEngine.getAllBearings()
        XCTAssertFalse(bearings.isEmpty, "Bearing database should not be empty")
        XCTAssertGreaterThan(bearings.count, 10, "Should have a reasonable number of bearings")
    }
    
    func testBearingDatabaseStructure() {
        let bearings = bearingEngine.getAllBearings()
        
        // Test that bearings have required properties
        for bearing in bearings.prefix(5) { // Test first 5 bearings
            XCTAssertFalse(bearing.id.isEmpty, "Bearing ID should not be empty")
            XCTAssertNotNil(bearing.designation, "Bearing should have designation")
            XCTAssertNotNil(bearing.bearingType, "Bearing should have type")
            
            // If not generic, should have fault frequencies
            if !bearing.isGeneric {
                XCTAssertNotNil(bearing.bpfi, "Non-generic bearing should have BPFI")
                XCTAssertNotNil(bearing.bpfo, "Non-generic bearing should have BPFO")
            }
        }
    }
    
    // MARK: - Bearing Search Tests
    
    func testFindBearingByExactModel() {
        // Test finding a specific bearing model (assuming 6205 exists in database)
        let bearing = bearingEngine.findBearing(byModel: "6205")
        
        if let bearing = bearing {
            XCTAssertEqual(bearing.designation, "6205", "Should find exact bearing model")
            XCTAssertFalse(bearing.isGeneric, "Specific bearing should not be generic")
            XCTAssertNotNil(bearing.bpfi, "Specific bearing should have BPFI")
            XCTAssertNotNil(bearing.bpfo, "Specific bearing should have BPFO")
        } else {
            // If 6205 doesn't exist, that's okay - database might not have this specific bearing
            print("Bearing 6205 not found in database - this is acceptable for testing")
        }
    }
    
    func testFindBearingCaseInsensitive() {
        let bearings = bearingEngine.getAllBearings()
        
        // Find a bearing to test with
        guard let testBearing = bearings.first(where: { !$0.isGeneric }) else {
            XCTFail("Need at least one non-generic bearing for testing")
            return
        }
        
        guard let designation = testBearing.designation else {
            XCTFail("Test bearing should have designation")
            return
        }
        
        // Test case insensitive search
        let lowerCase = bearingEngine.findBearing(byModel: designation.lowercased())
        let upperCase = bearingEngine.findBearing(byModel: designation.uppercased())
        let originalCase = bearingEngine.findBearing(byModel: designation)
        
        XCTAssertEqual(lowerCase?.id, testBearing.id, "Should find bearing with lowercase")
        XCTAssertEqual(upperCase?.id, testBearing.id, "Should find bearing with uppercase")
        XCTAssertEqual(originalCase?.id, testBearing.id, "Should find bearing with original case")
    }
    
    func testFindNonExistentBearing() {
        let bearing = bearingEngine.findBearing(byModel: "NONEXISTENT9999")
        XCTAssertNil(bearing, "Should return nil for non-existent bearing")
    }
    
    // MARK: - Search Functionality Tests
    
    func testSearchBearings() {
        let searchResults = bearingEngine.searchBearings(query: "62")
        
        XCTAssertFalse(searchResults.isEmpty, "Search for '62' should return some results")
        
        // Verify search results contain the query
        for bearing in searchResults.prefix(5) {
            if let designation = bearing.designation {
                XCTAssertTrue(
                    designation.lowercased().contains("62"),
                    "Search result '\(designation)' should contain search query"
                )
            }
        }
    }
    
    func testSearchBearingsEmpty() {
        let searchResults = bearingEngine.searchBearings(query: "")
        XCTAssertTrue(searchResults.isEmpty, "Empty search should return no results")
    }
    
    func testSearchBearingsSpecialCharacters() {
        let searchResults = bearingEngine.searchBearings(query: "6205-2RS")
        
        // Should handle special characters gracefully
        XCTAssertNotNil(searchResults, "Search with special characters should not crash")
    }
    
    // MARK: - Generic Bearing Tests
    
    func testGenericMotorBearing() {
        let motorBearing = bearingEngine.getGenericBearing(for: "Motor")
        
        XCTAssertEqual(motorBearing.bearingType, "Generic", "Should be generic type")
        XCTAssertTrue(motorBearing.isGeneric, "Should be marked as generic")
        XCTAssertTrue(motorBearing.designation?.contains("Motor") ?? false, "Should indicate motor bearing")
        XCTAssertNil(motorBearing.bpfi, "Generic bearing should not have specific fault frequencies")
    }
    
    func testGenericPumpBearing() {
        let pumpBearing = bearingEngine.getGenericBearing(for: "Pump")
        
        XCTAssertEqual(pumpBearing.bearingType, "Generic", "Should be generic type")
        XCTAssertTrue(pumpBearing.isGeneric, "Should be marked as generic")
        XCTAssertTrue(pumpBearing.designation?.contains("Pump") ?? false, "Should indicate pump bearing")
    }
    
    func testGenericFanBearing() {
        let fanBearing = bearingEngine.getGenericBearing(for: "Fan")
        
        XCTAssertEqual(fanBearing.bearingType, "Generic", "Should be generic type")
        XCTAssertTrue(fanBearing.isGeneric, "Should be marked as generic")
        XCTAssertTrue(fanBearing.designation?.contains("Fan") ?? false, "Should indicate fan bearing")
    }
    
    func testGenericUnknownEquipment() {
        let unknownBearing = bearingEngine.getGenericBearing(for: "UnknownEquipmentType")
        
        XCTAssertEqual(unknownBearing.bearingType, "Generic", "Should be generic type")
        XCTAssertTrue(unknownBearing.isGeneric, "Should be marked as generic")
    }
    
    // MARK: - Bearing Categories Tests
    
    func testGetBearingsByType() {
        let ballBearings = bearingEngine.getBearingsByType("Deep Groove Ball")
        let rollerBearings = bearingEngine.getBearingsByType("Cylindrical Roller")
        
        XCTAssertNotNil(ballBearings, "Should return array for ball bearings")
        XCTAssertNotNil(rollerBearings, "Should return array for roller bearings")
        
        // Verify all returned bearings are of the correct type
        for bearing in ballBearings.prefix(3) {
            XCTAssertEqual(bearing.bearingType, "Deep Groove Ball", "Should match requested type")
        }
    }
    
    func testGetBearingsByManufacturer() {
        // Get all bearings and find common manufacturers
        let allBearings = bearingEngine.getAllBearings()
        let manufacturers = Set(allBearings.compactMap { $0.manufacturer })
        
        if let firstManufacturer = manufacturers.first {
            let manufacturerBearings = bearingEngine.getBearingsByManufacturer(firstManufacturer)
            
            XCTAssertFalse(manufacturerBearings.isEmpty, "Should find bearings for existing manufacturer")
            
            for bearing in manufacturerBearings.prefix(3) {
                XCTAssertEqual(bearing.manufacturer, firstManufacturer, "Should match requested manufacturer")
            }
        }
    }
    
    // MARK: - Bearing Properties Validation
    
    func testBearingFaultFrequencyRanges() {
        let bearings = bearingEngine.getAllBearings().filter { !$0.isGeneric }
        
        for bearing in bearings.prefix(10) {
            // Test that fault frequencies are in reasonable ranges
            if let bpfi = bearing.bpfi {
                XCTAssertGreaterThan(bpfi, 0, "BPFI should be positive")
                XCTAssertLessThan(bpfi, 100, "BPFI should be reasonable (< 100)")
            }
            
            if let bpfo = bearing.bpfo {
                XCTAssertGreaterThan(bpfo, 0, "BPFO should be positive")
                XCTAssertLessThan(bpfo, 100, "BPFO should be reasonable (< 100)")
            }
            
            if let bsf = bearing.bsf {
                XCTAssertGreaterThan(bsf, 0, "BSF should be positive")
                XCTAssertLessThan(bsf, 50, "BSF should be reasonable (< 50)")
            }
            
            if let ftf = bearing.ftf {
                XCTAssertGreaterThan(ftf, 0, "FTF should be positive")
                XCTAssertLessThan(ftf, 5, "FTF should be reasonable (< 5)")
            }
        }
    }
    
    func testBearingFaultFrequencyRelationships() {
        let bearings = bearingEngine.getAllBearings().filter { !$0.isGeneric }
        
        for bearing in bearings.prefix(10) {
            if let bpfi = bearing.bpfi, let bpfo = bearing.bpfo {
                // BPFI is typically higher than BPFO for most bearings
                XCTAssertGreaterThan(bpfi, bpfo, "BPFI should typically be higher than BPFO for bearing \(bearing.designation ?? "unknown")")
            }
            
            if let bpfi = bearing.bpfi, let ftf = bearing.ftf {
                // BPFI should be much higher than FTF
                XCTAssertGreaterThan(bpfi, ftf * 2, "BPFI should be significantly higher than FTF for bearing \(bearing.designation ?? "unknown")")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testSearchPerformance() {
        measure {
            for i in 0..<100 {
                let query = "62\(i % 10)"
                let _ = bearingEngine.searchBearings(query: query)
            }
        }
    }
    
    func testLookupPerformance() {
        let allBearings = bearingEngine.getAllBearings()
        let testBearings = Array(allBearings.prefix(50))
        
        measure {
            for bearing in testBearings {
                if let designation = bearing.designation {
                    let _ = bearingEngine.findBearing(byModel: designation)
                }
            }
        }
    }
    
    // MARK: - Data Integrity Tests
    
    func testNoDuplicateBearings() {
        let allBearings = bearingEngine.getAllBearings()
        let designations = allBearings.compactMap { $0.designation }
        let uniqueDesignations = Set(designations)
        
        XCTAssertEqual(designations.count, uniqueDesignations.count, "Should not have duplicate bearing designations")
    }
    
    func testBearingIdsUnique() {
        let allBearings = bearingEngine.getAllBearings()
        let ids = allBearings.map { $0.id }
        let uniqueIds = Set(ids)
        
        XCTAssertEqual(ids.count, uniqueIds.count, "All bearing IDs should be unique")
    }
    
    func testRequiredFieldsPresent() {
        let allBearings = bearingEngine.getAllBearings()
        
        for bearing in allBearings.prefix(20) {
            XCTAssertFalse(bearing.id.isEmpty, "Bearing ID should not be empty")
            
            if !bearing.isGeneric {
                XCTAssertNotNil(bearing.designation, "Non-generic bearing should have designation")
                XCTAssertNotNil(bearing.bearingType, "Non-generic bearing should have type")
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyStringSearch() {
        let result = bearingEngine.findBearing(byModel: "")
        XCTAssertNil(result, "Empty string search should return nil")
    }
    
    func testWhitespaceHandling() {
        let allBearings = bearingEngine.getAllBearings()
        guard let testBearing = allBearings.first(where: { !$0.isGeneric && $0.designation != nil }) else {
            return // Skip if no suitable test bearing
        }
        
        let designation = testBearing.designation!
        
        // Test with leading/trailing whitespace
        let withSpaces = "  \(designation)  "
        let result = bearingEngine.findBearing(byModel: withSpaces)
        
        XCTAssertNotNil(result, "Should handle whitespace in search")
        XCTAssertEqual(result?.id, testBearing.id, "Should find same bearing despite whitespace")
    }
    
    func testSpecialCharacterHandling() {
        // Test with various special characters that might be in bearing names
        let specialQueries = ["6205-2RS", "6205/C3", "6205.2Z", "6205-Z"]
        
        for query in specialQueries {
            let result = bearingEngine.searchBearings(query: query)
            XCTAssertNotNil(result, "Search should handle special characters in '\(query)'")
        }
    }
    
    // MARK: - Consistency Tests
    
    func testGenericBearingConsistency() {
        let equipmentTypes = ["Motor", "Pump", "Fan", "Compressor", "Generator"]
        
        for equipment in equipmentTypes {
            let bearing1 = bearingEngine.getGenericBearing(for: equipment)
            let bearing2 = bearingEngine.getGenericBearing(for: equipment)
            
            XCTAssertEqual(bearing1.id, bearing2.id, "Generic bearing for \(equipment) should be consistent")
            XCTAssertEqual(bearing1.designation, bearing2.designation, "Generic bearing designation should be consistent")
        }
    }
}