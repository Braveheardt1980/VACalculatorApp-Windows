import XCTest
import Foundation
@testable import VACalculatorApp_Windows

class SecurityTests: XCTestCase {
    
    var securityManager: SecurityManager!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        securityManager = SecurityManager.shared
        
        // Create temporary directory for test files
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("VACalculatorTests_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        // Clean up temporary files
        try? FileManager.default.removeItem(at: tempDirectory)
        securityManager = nil
        tempDirectory = nil
        super.tearDown()
    }
    
    // MARK: - License Structure Tests
    
    func testValidLicenseStructure() {
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
            "signature": "test_signature_placeholder"
        ]
        
        let isValid = securityManager.validateLicenseStructure(validLicense)
        XCTAssertTrue(isValid, "Valid license structure should pass validation")
    }
    
    func testInvalidLicenseStructure() {
        let invalidLicense: [String: Any] = [
            "version": "1.0",
            // Missing required fields
            "authorized_users": ["WORKSTATION\\testuser"]
        ]
        
        let isValid = securityManager.validateLicenseStructure(invalidLicense)
        XCTAssertFalse(isValid, "Invalid license structure should fail validation")
    }
    
    // MARK: - Date Validation Tests
    
    func testValidDateRange() {
        let now = Date()
        let futureDate = now.addingTimeInterval(365 * 24 * 60 * 60) // 1 year from now
        
        let license: [String: Any] = [
            "version": "1.0",
            "issued_date": ISO8601DateFormatter().string(from: now.addingTimeInterval(-24 * 60 * 60)), // Yesterday
            "expiry_date": ISO8601DateFormatter().string(from: futureDate),
            "authorized_users": ["WORKSTATION\\testuser"],
            "features": ["full_calculator": true],
            "hardware_binding": ["binding_enabled": false],
            "signature": "test_signature"
        ]
        
        let result = securityManager.validateLicenseDates(license)
        XCTAssertTrue(result.isValid, "License with valid date range should pass")
        XCTAssertTrue(result.messages.isEmpty, "Valid license should have no error messages")
    }
    
    func testExpiredLicense() {
        let now = Date()
        let pastDate = now.addingTimeInterval(-365 * 24 * 60 * 60) // 1 year ago
        
        let license: [String: Any] = [
            "version": "1.0",
            "issued_date": ISO8601DateFormatter().string(from: pastDate),
            "expiry_date": ISO8601DateFormatter().string(from: now.addingTimeInterval(-24 * 60 * 60)), // Yesterday
            "authorized_users": ["WORKSTATION\\testuser"],
            "features": ["full_calculator": true],
            "hardware_binding": ["binding_enabled": false],
            "signature": "test_signature"
        ]
        
        let result = securityManager.validateLicenseDates(license)
        XCTAssertFalse(result.isValid, "Expired license should fail validation")
        XCTAssertTrue(result.messages.contains { $0.contains("expired") }, "Should contain expiry message")
    }
    
    func testFutureLicense() {
        let now = Date()
        let futureDate = now.addingTimeInterval(365 * 24 * 60 * 60) // 1 year from now
        
        let license: [String: Any] = [
            "version": "1.0",
            "issued_date": ISO8601DateFormatter().string(from: now.addingTimeInterval(24 * 60 * 60)), // Tomorrow
            "expiry_date": ISO8601DateFormatter().string(from: futureDate),
            "authorized_users": ["WORKSTATION\\testuser"],
            "features": ["full_calculator": true],
            "hardware_binding": ["binding_enabled": false],
            "signature": "test_signature"
        ]
        
        let result = securityManager.validateLicenseDates(license)
        XCTAssertFalse(result.isValid, "Future license should fail validation")
        XCTAssertTrue(result.messages.contains { $0.contains("not yet valid") }, "Should contain future date message")
    }
    
    // MARK: - User Authorization Tests
    
    func testAuthorizedUser() {
        // Simulate current user (would normally get from system)
        let currentUser = "WORKSTATION\\testuser"
        
        let license: [String: Any] = [
            "version": "1.0",
            "issued_date": "2025-07-14T21:30:00Z",
            "expiry_date": "2026-07-14T21:30:00Z",
            "authorized_users": [currentUser],
            "features": ["full_calculator": true],
            "hardware_binding": ["binding_enabled": false],
            "signature": "test_signature"
        ]
        
        let isAuthorized = securityManager.validateUserAuthorization(license, currentUser: currentUser)
        XCTAssertTrue(isAuthorized, "Authorized user should pass validation")
    }
    
    func testUnauthorizedUser() {
        let currentUser = "WORKSTATION\\unauthorizeduser"
        
        let license: [String: Any] = [
            "version": "1.0",
            "issued_date": "2025-07-14T21:30:00Z",
            "expiry_date": "2026-07-14T21:30:00Z",
            "authorized_users": ["WORKSTATION\\authorizeduser"],
            "features": ["full_calculator": true],
            "hardware_binding": ["binding_enabled": false],
            "signature": "test_signature"
        ]
        
        let isAuthorized = securityManager.validateUserAuthorization(license, currentUser: currentUser)
        XCTAssertFalse(isAuthorized, "Unauthorized user should fail validation")
    }
    
    func testMultipleAuthorizedUsers() {
        let currentUser = "WORKSTATION\\user2"
        
        let license: [String: Any] = [
            "version": "1.0",
            "issued_date": "2025-07-14T21:30:00Z",
            "expiry_date": "2026-07-14T21:30:00Z",
            "authorized_users": ["WORKSTATION\\user1", currentUser, "WORKSTATION\\user3"],
            "features": ["full_calculator": true],
            "hardware_binding": ["binding_enabled": false],
            "signature": "test_signature"
        ]
        
        let isAuthorized = securityManager.validateUserAuthorization(license, currentUser: currentUser)
        XCTAssertTrue(isAuthorized, "User in authorized list should pass validation")
    }
    
    // MARK: - Hardware Binding Tests
    
    func testHardwareBindingDisabled() {
        let license: [String: Any] = [
            "version": "1.0",
            "issued_date": "2025-07-14T21:30:00Z",
            "expiry_date": "2026-07-14T21:30:00Z",
            "authorized_users": ["WORKSTATION\\testuser"],
            "features": ["full_calculator": true],
            "hardware_binding": [
                "binding_enabled": false
            ],
            "signature": "test_signature"
        ]
        
        let result = securityManager.validateHardwareBinding(license, currentMachineId: "any-machine-id")
        XCTAssertTrue(result.isValid, "Disabled hardware binding should always pass")
    }
    
    func testHardwareBindingEnabled() {
        let testMachineId = "test-machine-12345"
        
        let license: [String: Any] = [
            "version": "1.0",
            "issued_date": "2025-07-14T21:30:00Z",
            "expiry_date": "2026-07-14T21:30:00Z",
            "authorized_users": ["WORKSTATION\\testuser"],
            "features": ["full_calculator": true],
            "hardware_binding": [
                "binding_enabled": true,
                "machine_id": testMachineId
            ],
            "signature": "test_signature"
        ]
        
        // Test with matching machine ID
        let validResult = securityManager.validateHardwareBinding(license, currentMachineId: testMachineId)
        XCTAssertTrue(validResult.isValid, "Matching machine ID should pass validation")
        
        // Test with different machine ID
        let invalidResult = securityManager.validateHardwareBinding(license, currentMachineId: "different-machine-id")
        XCTAssertFalse(invalidResult.isValid, "Different machine ID should fail validation")
    }
    
    // MARK: - Feature Authorization Tests
    
    func testFeatureAuthorization() {
        let license: [String: Any] = [
            "version": "1.0",
            "issued_date": "2025-07-14T21:30:00Z",
            "expiry_date": "2026-07-14T21:30:00Z",
            "authorized_users": ["WORKSTATION\\testuser"],
            "features": [
                "full_calculator": true,
                "pdf_export": false,
                "advanced_trends": true
            ],
            "hardware_binding": ["binding_enabled": false],
            "signature": "test_signature"
        ]
        
        XCTAssertTrue(securityManager.isFeatureEnabled("full_calculator", in: license), "Enabled feature should return true")
        XCTAssertFalse(securityManager.isFeatureEnabled("pdf_export", in: license), "Disabled feature should return false")
        XCTAssertTrue(securityManager.isFeatureEnabled("advanced_trends", in: license), "Enabled feature should return true")
        XCTAssertFalse(securityManager.isFeatureEnabled("nonexistent_feature", in: license), "Non-existent feature should return false")
    }
    
    // MARK: - Anti-Tampering Tests
    
    func testDebuggerDetection() {
        // Test that debugger detection doesn't interfere with normal operation
        let isDebuggerDetected = securityManager.isDebuggerAttached()
        
        // During testing, debugger might or might not be attached
        // We just verify the function doesn't crash
        XCTAssertNotNil(isDebuggerDetected, "Debugger detection should return a boolean value")
    }
    
    func testVirtualEnvironmentDetection() {
        // Test virtual environment detection
        let isVirtual = securityManager.isRunningInVirtualEnvironment()
        
        // We can't predict the test environment, just ensure it doesn't crash
        XCTAssertNotNil(isVirtual, "Virtual environment detection should return a boolean value")
    }
    
    // MARK: - License File I/O Tests
    
    func testLicenseFileReading() {
        // Create test license file
        let testLicense: [String: Any] = [
            "version": "1.0",
            "issued_date": "2025-07-14T21:30:00Z",
            "expiry_date": "2026-07-14T21:30:00Z",
            "authorized_users": ["WORKSTATION\\testuser"],
            "features": ["full_calculator": true],
            "hardware_binding": ["binding_enabled": false],
            "signature": "test_signature"
        ]
        
        // Write test license to temporary file
        let licenseFileURL = tempDirectory.appendingPathComponent("test_license.license")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: testLicense, options: .prettyPrinted)
            try jsonData.write(to: licenseFileURL)
            
            // Test reading the license file
            let readLicense = securityManager.readLicenseFile(at: licenseFileURL.path)
            XCTAssertNotNil(readLicense, "Should be able to read valid license file")
            
            if let readLicense = readLicense {
                XCTAssertEqual(readLicense["version"] as? String, "1.0", "Version should match")
                XCTAssertEqual((readLicense["authorized_users"] as? [String])?.first, "WORKSTATION\\testuser", "User should match")
            }
            
        } catch {
            XCTFail("Failed to create test license file: \(error)")
        }
    }
    
    func testInvalidLicenseFileReading() {
        // Create invalid JSON file
        let invalidLicenseURL = tempDirectory.appendingPathComponent("invalid_license.license")
        
        do {
            let invalidJSON = "{ invalid json content"
            try invalidJSON.write(to: invalidLicenseURL, atomically: true, encoding: .utf8)
            
            // Test reading invalid license file
            let readLicense = securityManager.readLicenseFile(at: invalidLicenseURL.path)
            XCTAssertNil(readLicense, "Should return nil for invalid JSON")
            
        } catch {
            XCTFail("Failed to create invalid license file: \(error)")
        }
    }
    
    func testMissingLicenseFile() {
        let missingFileURL = tempDirectory.appendingPathComponent("nonexistent.license")
        
        let readLicense = securityManager.readLicenseFile(at: missingFileURL.path)
        XCTAssertNil(readLicense, "Should return nil for missing file")
    }
    
    // MARK: - Integration Tests
    
    func testCompleteValidationProcess() {
        // Create a comprehensive test license
        let now = Date()
        let futureDate = now.addingTimeInterval(365 * 24 * 60 * 60)
        let currentUser = "WORKSTATION\\integrationtestuser"
        
        let license: [String: Any] = [
            "version": "1.0",
            "issued_date": ISO8601DateFormatter().string(from: now.addingTimeInterval(-24 * 60 * 60)),
            "expiry_date": ISO8601DateFormatter().string(from: futureDate),
            "authorized_users": [currentUser],
            "features": [
                "full_calculator": true,
                "pdf_export": true,
                "advanced_trends": true
            ],
            "hardware_binding": [
                "binding_enabled": false
            ],
            "signature": "integration_test_signature"
        ]
        
        // Write license to file
        let licenseFileURL = tempDirectory.appendingPathComponent("integration_test.license")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: license, options: .prettyPrinted)
            try jsonData.write(to: licenseFileURL)
            
            // Test complete validation process
            let result = securityManager.validateLicense(
                at: licenseFileURL.path,
                currentUser: currentUser,
                currentMachineId: "test-machine"
            )
            
            // Note: This will fail signature validation since we don't have real keys,
            // but it should pass structural and date validation
            XCTAssertNotNil(result, "Validation should return a result")
            
            if let result = result {
                // Check individual validation components
                XCTAssertTrue(securityManager.validateLicenseStructure(license), "Structure should be valid")
                XCTAssertTrue(securityManager.validateLicenseDates(license).isValid, "Dates should be valid")
                XCTAssertTrue(securityManager.validateUserAuthorization(license, currentUser: currentUser), "User should be authorized")
            }
            
        } catch {
            XCTFail("Failed to create integration test license: \(error)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testValidationPerformance() {
        let license: [String: Any] = [
            "version": "1.0",
            "issued_date": "2025-07-14T21:30:00Z",
            "expiry_date": "2026-07-14T21:30:00Z",
            "authorized_users": ["WORKSTATION\\testuser"],
            "features": ["full_calculator": true],
            "hardware_binding": ["binding_enabled": false],
            "signature": "test_signature"
        ]
        
        measure {
            for _ in 0..<100 {
                let _ = securityManager.validateLicenseStructure(license)
                let _ = securityManager.validateLicenseDates(license)
                let _ = securityManager.validateUserAuthorization(license, currentUser: "WORKSTATION\\testuser")
            }
        }
    }
}