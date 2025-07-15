import Foundation
import CryptoSwift
import Crypto

// MARK: - Security Manager
// Handles license validation, user authentication, and anti-tampering

class SecurityManager: ObservableObject {
    static let shared = SecurityManager()
    
    // MARK: - Properties
    
    private let licenseFileName = "va_calculator.license"
    private let whitelistFileName = "authorized_users.enc"
    private let publicKeyPEM = """
    -----BEGIN PUBLIC KEY-----
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2rT5T3X6y5L+8mN9dGfW
    aBcDeFgHiJkLmNoPqRsTuVwXyZ1A2bC3dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE
    4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGh
    I5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jK
    lMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnO
    pQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrS
    tUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvW
    xYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA
    1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2
    dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4f
    GhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5
    jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlM
    nOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQ
    rStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStU
    vWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxY
    zA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1b
    C2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE
    4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGh
    I5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jK
    lMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnO
    pQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrS
    tUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvW
    xYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA
    1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2
    dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4f
    GhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5
    jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlM
    nOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQ
    rStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStU
    vWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxY
    zA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1bC2dE4fGhI5jKlMnOpQrStUvWxYzA1b
    QIDAQAB
    -----END PUBLIC KEY-----
    """
    
    @Published var isLicenseValid = false
    @Published var currentUser: String = ""
    @Published var licenseExpiryDate: Date?
    @Published var authorizedFeatures: Set<String> = []
    
    private init() {}
    
    // MARK: - Security Initialization
    
    func initializeSecuritySystem() {
        #if DEBUG
        print("🔐 SecurityManager: Initializing security system...")
        #endif
        
        // Detect debugging/analysis environment
        if isRunningInAnalysisEnvironment() {
            #if DEBUG
            print("⚠️ SecurityManager: Analysis environment detected")
            #endif
            // In production, this would terminate the application
        }
        
        // Get current Windows user
        currentUser = getCurrentWindowsUser()
        
        #if DEBUG
        print("🔐 SecurityManager: Current user: \(currentUser)")
        #endif
    }
    
    // MARK: - License Validation
    
    enum ValidationError: LocalizedError {
        case licenseFileNotFound
        case invalidLicenseFormat
        case signatureVerificationFailed
        case userNotAuthorized
        case licenseExpired
        case hardwareMismatch
        case tamperingDetected
        
        var errorDescription: String? {
            switch self {
            case .licenseFileNotFound:
                return "License file not found. Please contact your administrator to obtain a valid license."
            case .invalidLicenseFormat:
                return "Invalid license file format. The license file may be corrupted."
            case .signatureVerificationFailed:
                return "License signature verification failed. The license file may have been tampered with."
            case .userNotAuthorized:
                return "Your Windows account is not authorized to use this application. Please contact your administrator."
            case .licenseExpired:
                return "Your license has expired. Please contact your administrator to renew your license."
            case .hardwareMismatch:
                return "This license is not valid for this computer. Please contact your administrator."
            case .tamperingDetected:
                return "Application tampering detected. Please reinstall the application from the original source."
            }
        }
    }
    
    func validateLicense() -> Result<Void, ValidationError> {
        #if DEBUG
        print("🔐 SecurityManager: Starting license validation...")
        #endif
        
        // Step 1: Check if license file exists
        guard let licenseData = loadLicenseFile() else {
            return .failure(.licenseFileNotFound)
        }
        
        // Step 2: Parse license file
        guard let license = parseLicenseData(licenseData) else {
            return .failure(.invalidLicenseFormat)
        }
        
        // Step 3: Verify digital signature
        guard verifyLicenseSignature(license: license) else {
            return .failure(.signatureVerificationFailed)
        }
        
        // Step 4: Check expiry date
        if license.expiryDate < Date() {
            return .failure(.licenseExpired)
        }
        
        // Step 5: Validate user authorization
        guard license.authorizedUsers.contains(currentUser) else {
            return .failure(.userNotAuthorized)
        }
        
        // Step 6: Verify hardware binding
        guard verifyHardwareBinding(license: license) else {
            return .failure(.hardwareMismatch)
        }
        
        // Step 7: Check for tampering
        guard !isTamperingDetected() else {
            return .failure(.tamperingDetected)
        }
        
        // All validations passed
        isLicenseValid = true
        licenseExpiryDate = license.expiryDate
        authorizedFeatures = Set(license.features.keys.filter { license.features[$0] == true })
        
        #if DEBUG
        print("✅ SecurityManager: License validation successful")
        print("🔐 SecurityManager: Authorized features: \(authorizedFeatures)")
        print("🔐 SecurityManager: License expires: \(license.expiryDate)")
        #endif
        
        return .success(())
    }
    
    // MARK: - Private Helper Methods
    
    private func loadLicenseFile() -> Data? {
        // Try multiple possible license locations
        let possiblePaths = [
            // Current directory
            licenseFileName,
            // Application directory
            Bundle.main.bundlePath + "/" + licenseFileName,
            // Documents directory
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(licenseFileName).path ?? "",
            // Application support directory
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("VA Calculator").appendingPathComponent(licenseFileName).path ?? ""
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                #if DEBUG
                print("🔐 SecurityManager: Found license at: \(path)")
                #endif
                return FileManager.default.contents(atPath: path)
            }
        }
        
        #if DEBUG
        print("❌ SecurityManager: License file not found in any of the expected locations")
        #endif
        return nil
    }
    
    private func parseLicenseData(_ data: Data) -> LicenseFile? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(LicenseFile.self, from: data)
        } catch {
            #if DEBUG
            print("❌ SecurityManager: Failed to parse license: \(error)")
            #endif
            return nil
        }
    }
    
    private func verifyLicenseSignature(license: LicenseFile) -> Bool {
        // TODO: Implement proper RSA signature verification
        // For now, return true for development
        #if DEBUG
        print("🔐 SecurityManager: Signature verification (TODO: implement RSA verification)")
        #endif
        return true
    }
    
    private func verifyHardwareBinding(license: LicenseFile) -> Bool {
        let currentFingerprint = generateHardwareFingerprint()
        
        if let licenseFingerprint = license.hardwareBinding?.fingerprint {
            let matches = currentFingerprint == licenseFingerprint
            #if DEBUG
            print("🔐 SecurityManager: Hardware fingerprint check: \(matches ? "MATCH" : "MISMATCH")")
            print("🔐 Current: \(currentFingerprint)")
            print("🔐 License: \(licenseFingerprint)")
            #endif
            return matches
        }
        
        // If no hardware binding specified, allow execution
        #if DEBUG
        print("🔐 SecurityManager: No hardware binding in license")
        #endif
        return true
    }
    
    private func generateHardwareFingerprint() -> String {
        // TODO: Implement proper hardware fingerprinting for Windows
        // For now, return a mock fingerprint
        let mockComponents = [
            "MOCK_CPU_ID",
            "MOCK_MOTHERBOARD_SERIAL",
            "MOCK_DISK_SERIAL"
        ]
        
        let combined = mockComponents.joined(separator: "_")
        let data = combined.data(using: .utf8) ?? Data()
        let hash = SHA256.hash(data: data)
        
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func getCurrentWindowsUser() -> String {
        // Get current Windows user account name
        if let username = ProcessInfo.processInfo.environment["USERNAME"],
           let computername = ProcessInfo.processInfo.environment["COMPUTERNAME"] {
            return "\\(computername)\\\\(username)"
        } else if let user = ProcessInfo.processInfo.environment["USER"] {
            return "LOCAL\\\\(user)"
        } else {
            return "UNKNOWN\\unknown"
        }
    }
    
    private func isRunningInAnalysisEnvironment() -> Bool {
        // Check for common debugging/analysis indicators
        
        // Check for debugger
        if isDebuggerAttached() {
            return true
        }
        
        // Check for virtual machine indicators
        if isRunningInVM() {
            return true
        }
        
        // Check for known analysis tools
        if hasAnalysisToolsRunning() {
            return true
        }
        
        return false
    }
    
    private func isDebuggerAttached() -> Bool {
        // TODO: Implement proper debugger detection for Windows
        return false
    }
    
    private func isRunningInVM() -> Bool {
        // TODO: Implement VM detection for Windows
        return false
    }
    
    private func hasAnalysisToolsRunning() -> Bool {
        // TODO: Implement analysis tool detection
        return false
    }
    
    private func isTamperingDetected() -> Bool {
        // TODO: Implement application integrity checking
        return false
    }
}

// MARK: - License File Structure

struct LicenseFile: Codable {
    let licenseVersion: String
    let applicationId: String
    let issuedDate: Date
    let expiryDate: Date
    let licenseType: String
    let authorizedUsers: [String]
    let hardwareBinding: HardwareBinding?
    let features: [String: Bool]
    let licenseData: LicenseData
    let signature: String
    
    enum CodingKeys: String, CodingKey {
        case licenseVersion = "license_version"
        case applicationId = "application_id"
        case issuedDate = "issued_date"
        case expiryDate = "expiry_date"
        case licenseType = "license_type"
        case authorizedUsers = "authorized_users"
        case hardwareBinding = "hardware_binding"
        case features
        case licenseData = "license_data"
        case signature
    }
}

struct HardwareBinding: Codable {
    let fingerprint: String
    let tolerance: String
}

struct LicenseData: Codable {
    let organization: String
    let contact: String
    let userLimit: Int
    
    enum CodingKeys: String, CodingKey {
        case organization
        case contact
        case userLimit = "user_limit"
    }
}

// MARK: - Public Interface

extension SecurityManager {
    
    /// Check if a specific feature is authorized
    func isFeatureAuthorized(_ feature: String) -> Bool {
        return isLicenseValid && authorizedFeatures.contains(feature)
    }
    
    /// Get days until license expires
    var daysUntilExpiry: Int? {
        guard let expiryDate = licenseExpiryDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day
        return max(0, days ?? 0)
    }
    
    /// Periodic validation (call from app timer)
    func performPeriodicValidation() {
        let result = validateLicense()
        if case .failure = result {
            isLicenseValid = false
        }
    }
}