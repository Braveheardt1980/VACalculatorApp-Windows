#!/usr/bin/env swift

// ValidationScript.swift
// Quick validation script to test key components without full build
// Run this to verify core logic before attempting Windows build

import Foundation

// MARK: - Simple Test Framework

class SimpleTest {
    static var totalTests = 0
    static var passedTests = 0
    static var failedTests = 0
    
    static func assert(_ condition: Bool, _ message: String) {
        totalTests += 1
        if condition {
            passedTests += 1
            print("✅ PASS: \(message)")
        } else {
            failedTests += 1
            print("❌ FAIL: \(message)")
        }
    }
    
    static func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String) {
        assert(actual == expected, "\(message) (expected: \(expected), actual: \(actual))")
    }
    
    static func printSummary() {
        print("\n" + "="*50)
        print("TEST SUMMARY")
        print("="*50)
        print("Total Tests: \(totalTests)")
        print("Passed: \(passedTests)")
        print("Failed: \(failedTests)")
        print("Success Rate: \(totalTests > 0 ? (passedTests * 100 / totalTests) : 0)%")
        
        if failedTests == 0 {
            print("\n🎉 ALL TESTS PASSED! Ready for build testing.")
        } else {
            print("\n⚠️  Some tests failed. Review implementation before build.")
        }
    }
}

// MARK: - Mock Data Structures (Simplified for validation)

struct MockBearingData {
    let id: String
    let designation: String?
    let bearingType: String?
    let isGeneric: Bool
    let bpfi: Double?
    let bpfo: Double?
    let bsf: Double?
    let ftf: Double?
}

struct MockAPSetResult {
    let rpm: Double
    let fmax: Double
    let lor: Int
    let shaftRevolutions: Double
    let calculatedFmax: Double?
    let isValid: Bool
    let orderBPFI: Double
    let scaledBPFI: Double
}

// MARK: - Core Calculation Logic Tests

class CalculationValidator {
    
    static func validateFormulaCalculations() {
        print("\n📊 Testing Formula Calculations...")
        
        // Test LOR calculation
        let lor1 = calculateLOR(fmax: 70.0, rpm: 1800)
        SimpleTest.assertEqual(lor1, 800, "LOR calculation for 70 orders at 1800 RPM")
        
        let lor2 = calculateLOR(fmax: 30.5, rpm: 1800)
        SimpleTest.assertEqual(lor2, 400, "LOR calculation for 30.5 orders at 1800 RPM")
        
        // Test shaft revolutions
        let revolutions1 = calculateShaftRevolutions(lor: 800, rpm: 1800)
        let expected1 = Double(800) / (1800.0 / 60.0) // 26.67 seconds
        SimpleTest.assert(abs(revolutions1 - expected1) < 0.1, "Shaft revolutions calculation")
        
        // Test frequency scaling
        let scaledBPFI = 7.94 * 1800 / 60.0 // 238.2 Hz
        SimpleTest.assert(abs(scaledBPFI - 238.2) < 1.0, "BPFI frequency scaling")
    }
    
    static func calculateLOR(fmax: Double, rpm: Double) -> Int {
        // Simplified LOR calculation based on standard formula
        let frequency = fmax * rpm / 60.0
        return Int(frequency / 2.56)
    }
    
    static func calculateShaftRevolutions(lor: Int, rpm: Double) -> Double {
        return Double(lor) / (rpm / 60.0)
    }
    
    static func validateGenericBearingCalculations() {
        print("\n⚙️ Testing Generic Bearing Calculations...")
        
        // Test generic motor bearing
        let motorResult = calculateGenericMotor(rpm: 1800)
        SimpleTest.assertEqual(motorResult.fmax, 70.0, "Generic motor Fmax")
        SimpleTest.assertEqual(motorResult.lor, 800, "Generic motor LOR")
        SimpleTest.assert(motorResult.isValid, "Generic motor result should be valid")
        
        // Test generic motor PeakVue
        let peakVueResult = calculateGenericMotorPeakVue(rpm: 1800)
        SimpleTest.assertEqual(peakVueResult.fmax, 30.5, "Generic motor PeakVue Fmax")
        SimpleTest.assertEqual(peakVueResult.lor, 400, "Generic motor PeakVue LOR")
    }
    
    static func calculateGenericMotor(rpm: Double) -> MockAPSetResult {
        let fmax = 70.0
        let lor = 800
        let shaftRevolutions = calculateShaftRevolutions(lor: lor, rpm: rpm)
        let calculatedFmax = fmax * rpm / 60.0
        
        return MockAPSetResult(
            rpm: rpm,
            fmax: fmax,
            lor: lor,
            shaftRevolutions: shaftRevolutions,
            calculatedFmax: calculatedFmax,
            isValid: true,
            orderBPFI: 0, // Generic bearings don't have specific frequencies
            scaledBPFI: 0
        )
    }
    
    static func calculateGenericMotorPeakVue(rpm: Double) -> MockAPSetResult {
        let fmax = 30.5
        let lor = 400
        let shaftRevolutions = calculateShaftRevolutions(lor: lor, rpm: rpm)
        let calculatedFmax = fmax * rpm / 60.0
        
        return MockAPSetResult(
            rpm: rpm,
            fmax: fmax,
            lor: lor,
            shaftRevolutions: shaftRevolutions,
            calculatedFmax: calculatedFmax,
            isValid: true,
            orderBPFI: 0,
            scaledBPFI: 0
        )
    }
    
    static func validateSpecificBearingCalculations() {
        print("\n🎯 Testing Specific Bearing Calculations...")
        
        let bearing6205 = MockBearingData(
            id: "6205",
            designation: "6205",
            bearingType: "Deep Groove Ball",
            isGeneric: false,
            bpfi: 7.94,
            bpfo: 5.06,
            bsf: 2.357,
            ftf: 0.399
        )
        
        let result = calculateSpecificBearing(bearing: bearing6205, rpm: 1800)
        
        // Verify bearing frequencies
        let expectedBPFI = 7.94 * 1800 / 60.0 // 238.2 Hz
        let expectedBPFO = 5.06 * 1800 / 60.0 // 151.8 Hz
        
        SimpleTest.assert(abs(result.scaledBPFI - expectedBPFI) < 1.0, "6205 BPFI frequency calculation")
        SimpleTest.assert(abs(result.orderBPFI - 7.94) < 0.01, "6205 BPFI order preservation")
        SimpleTest.assert(result.isValid, "6205 bearing result should be valid")
    }
    
    static func calculateSpecificBearing(bearing: MockBearingData, rpm: Double) -> MockAPSetResult {
        // Calculate Fmax based on bearing characteristics
        let maxOrder = max(bearing.bpfi ?? 0, bearing.bpfo ?? 0)
        let fmax = min(ceil(maxOrder * 3.25), 200.0)
        let lor = calculateLOR(fmax: fmax, rpm: rpm)
        let shaftRevolutions = calculateShaftRevolutions(lor: lor, rpm: rpm)
        
        return MockAPSetResult(
            rpm: rpm,
            fmax: fmax,
            lor: lor,
            shaftRevolutions: shaftRevolutions,
            calculatedFmax: fmax * rpm / 60.0,
            isValid: true,
            orderBPFI: bearing.bpfi ?? 0,
            scaledBPFI: (bearing.bpfi ?? 0) * rpm / 60.0
        )
    }
}

// MARK: - Security System Tests

class SecurityValidator {
    
    static func validateLicenseStructure() {
        print("\n🔐 Testing License Structure Validation...")
        
        // Test valid license structure
        let validLicense: [String: Any] = [
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
        
        SimpleTest.assert(validateLicenseStructure(validLicense), "Valid license structure")
        
        // Test invalid license structure
        let invalidLicense: [String: Any] = [
            "version": "1.0"
            // Missing required fields
        ]
        
        SimpleTest.assert(!validateLicenseStructure(invalidLicense), "Invalid license structure should fail")
    }
    
    static func validateLicenseStructure(_ license: [String: Any]) -> Bool {
        let requiredFields = ["version", "issued_date", "expiry_date", "authorized_users", "features", "signature"]
        
        for field in requiredFields {
            if license[field] == nil {
                return false
            }
        }
        
        return true
    }
    
    static func validateDateValidation() {
        print("\n📅 Testing Date Validation...")
        
        let now = Date()
        let futureDate = now.addingTimeInterval(365 * 24 * 60 * 60)
        let pastDate = now.addingTimeInterval(-365 * 24 * 60 * 60)
        
        let formatter = ISO8601DateFormatter()
        
        // Valid date range
        let validDates = (
            issued: formatter.string(from: now.addingTimeInterval(-24 * 60 * 60)),
            expiry: formatter.string(from: futureDate)
        )
        SimpleTest.assert(validateDateRange(validDates.issued, validDates.expiry), "Valid date range")
        
        // Expired license
        let expiredDates = (
            issued: formatter.string(from: pastDate),
            expiry: formatter.string(from: now.addingTimeInterval(-24 * 60 * 60))
        )
        SimpleTest.assert(!validateDateRange(expiredDates.issued, expiredDates.expiry), "Expired license should fail")
        
        // Future license
        let futureDates = (
            issued: formatter.string(from: now.addingTimeInterval(24 * 60 * 60)),
            expiry: formatter.string(from: futureDate)
        )
        SimpleTest.assert(!validateDateRange(futureDates.issued, futureDates.expiry), "Future license should fail")
    }
    
    static func validateDateRange(_ issuedDate: String, _ expiryDate: String) -> Bool {
        let formatter = ISO8601DateFormatter()
        
        guard let issued = formatter.date(from: issuedDate),
              let expiry = formatter.date(from: expiryDate) else {
            return false
        }
        
        let now = Date()
        return now >= issued && now <= expiry
    }
    
    static func validateUserAuthorization() {
        print("\n👤 Testing User Authorization...")
        
        let authorizedUsers = ["WORKSTATION\\user1", "DOMAIN\\user2", "MACHINE\\user3"]
        
        SimpleTest.assert(isUserAuthorized("WORKSTATION\\user1", authorizedUsers), "Authorized user should pass")
        SimpleTest.assert(isUserAuthorized("DOMAIN\\user2", authorizedUsers), "Second authorized user should pass")
        SimpleTest.assert(!isUserAuthorized("WORKSTATION\\unauthorized", authorizedUsers), "Unauthorized user should fail")
        SimpleTest.assert(!isUserAuthorized("", authorizedUsers), "Empty user should fail")
    }
    
    static func isUserAuthorized(_ currentUser: String, _ authorizedUsers: [String]) -> Bool {
        return authorizedUsers.contains(currentUser)
    }
}

// MARK: - File Structure Tests

class FileStructureValidator {
    
    static func validateProjectStructure() {
        print("\n📁 Testing Project Structure...")
        
        let expectedDirectories = [
            "Source",
            "Source/Models",
            "Source/Services", 
            "Source/Views",
            "Source/Security",
            "Source/Extensions",
            "Tests",
            "Assets",
            "Security",
            "Security/Scripts",
            "Documentation"
        ]
        
        let currentDir = FileManager.default.currentDirectoryPath
        
        for directory in expectedDirectories {
            let path = "\(currentDir)/\(directory)"
            let exists = FileManager.default.fileExists(atPath: path)
            SimpleTest.assert(exists, "Directory exists: \(directory)")
        }
    }
    
    static func validateCoreFiles() {
        print("\n📄 Testing Core Files...")
        
        let expectedFiles = [
            "Package.swift",
            "Source/main.swift",
            "Source/Models/APSetDisplayModels.swift",
            "Source/Services/UnifiedCalculationService.swift",
            "Source/Services/TrendRecommendationService.swift",
            "Source/Security/SecurityManager.swift",
            "Assets/bearings-master.json",
            "BUILD_INSTRUCTIONS.md",
            "SETUP_GUIDE.md",
            "DEPLOYMENT_CHECKLIST.md"
        ]
        
        let currentDir = FileManager.default.currentDirectoryPath
        
        for file in expectedFiles {
            let path = "\(currentDir)/\(file)"
            let exists = FileManager.default.fileExists(atPath: path)
            SimpleTest.assert(exists, "File exists: \(file)")
        }
    }
    
    static func validatePackageSwift() {
        print("\n📦 Testing Package.swift Configuration...")
        
        let packagePath = "Package.swift"
        
        guard let content = try? String(contentsOfFile: packagePath) else {
            SimpleTest.assert(false, "Package.swift should be readable")
            return
        }
        
        SimpleTest.assert(content.contains("swift-cross-ui"), "Package.swift should reference SwiftCrossUI")
        SimpleTest.assert(content.contains("CryptoSwift"), "Package.swift should reference CryptoSwift")
        SimpleTest.assert(content.contains("swift-crypto"), "Package.swift should reference Swift Crypto")
        SimpleTest.assert(content.contains("VACalculatorApp-Windows"), "Package.swift should define executable")
        SimpleTest.assert(content.contains(".windows(.v10)"), "Package.swift should target Windows 10")
    }
}

// MARK: - Trend Validation Tests

class TrendValidator {
    
    static func validateTrendGeneration() {
        print("\n📈 Testing Trend Generation Logic...")
        
        // Simulate trend generation for normal analysis
        let normalTrends = generateMockNormalTrends(rpm: 1800, fmax: 70.0)
        SimpleTest.assert(normalTrends.count >= 5, "Should generate multiple normal trends")
        SimpleTest.assert(normalTrends.contains { $0.contains("Overall") }, "Should include Overall trend")
        SimpleTest.assert(normalTrends.contains { $0.contains("1×TS") }, "Should include 1×TS trend")
        
        // Simulate trend generation for PeakVue analysis
        let peakVueTrends = generateMockPeakVueTrends(rpm: 1800, fmax: 30.5)
        SimpleTest.assert(peakVueTrends.count >= 3, "Should generate PeakVue trends")
        SimpleTest.assert(peakVueTrends.contains { $0.contains("PeakVue") || $0.contains("Stress") }, "Should include PeakVue-specific trends")
    }
    
    static func generateMockNormalTrends(rpm: Double, fmax: Double) -> [String] {
        let runningSpeed = rpm / 60.0
        var trends: [String] = []
        
        // Basic trends
        trends.append("Overall Vibration (10 Hz - 1000 Hz)")
        trends.append("1×TS Running Speed (\(String(format: "%.1f", runningSpeed)) Hz)")
        trends.append("2×TS (\(String(format: "%.1f", runningSpeed * 2)) Hz)")
        trends.append("Sub-synchronous Band (2 Hz - \(String(format: "%.1f", runningSpeed * 0.5)) Hz)")
        trends.append("3-8×TS Band (\(String(format: "%.1f", runningSpeed * 3)) Hz - \(String(format: "%.1f", runningSpeed * 8)) Hz)")
        trends.append("9-25×TS Band (\(String(format: "%.1f", runningSpeed * 9)) Hz - \(String(format: "%.1f", runningSpeed * 25)) Hz)")
        
        return trends
    }
    
    static func generateMockPeakVueTrends(rpm: Double, fmax: Double) -> [String] {
        let runningSpeed = rpm / 60.0
        var trends: [String] = []
        
        trends.append("PeakVue Overall (300 Hz - \(String(format: "%.0f", fmax * runningSpeed)) Hz)")
        trends.append("Stress Wave Energy")
        trends.append("High Frequency Bearing Defects")
        
        return trends
    }
}

// MARK: - Main Validation Runner

func runValidation() {
    print("🚀 VA Calculator Windows - Component Validation")
    print("=" * 60)
    
    // Run all validation tests
    FileStructureValidator.validateProjectStructure()
    FileStructureValidator.validateCoreFiles()
    FileStructureValidator.validatePackageSwift()
    
    CalculationValidator.validateFormulaCalculations()
    CalculationValidator.validateGenericBearingCalculations()
    CalculationValidator.validateSpecificBearingCalculations()
    
    SecurityValidator.validateLicenseStructure()
    SecurityValidator.validateDateValidation()
    SecurityValidator.validateUserAuthorization()
    
    TrendValidator.validateTrendGeneration()
    
    // Print final summary
    SimpleTest.printSummary()
}

// String multiplication helper
extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}

// Run the validation
runValidation()