# Security Implementation Guide

## Overview

The VA Calculator App Windows edition implements a comprehensive security system to prevent unauthorized use and ensure only licensed users can access the application.

## Security Architecture

### 1. RSA Digital Signature System

**Purpose**: Prevent license file tampering and ensure authenticity

**Implementation**:
- 2048-bit RSA key pair generation
- Private key for signing licenses (kept secure)
- Public key embedded in application for verification
- Digital signatures on all license files

**Key Generation**:
```bash
# Generate private key
openssl genrsa -out private_key.pem 2048

# Extract public key
openssl rsa -in private_key.pem -outform PEM -pubout -out public_key.pem
```

### 2. Encrypted User Whitelist

**Purpose**: Control which Windows users can run the application

**Format**:
```json
{
  "authorized_users": [
    "WORKSTATION\\john.smith",
    "DOMAIN\\jane.doe", 
    "LOCAL\\admin"
  ],
  "created_date": "2025-07-14T21:30:00Z",
  "version": "1.0"
}
```

**Encryption**: AES-256-GCM with key derived from application secrets

### 3. Hardware Fingerprinting

**Purpose**: Tie licenses to specific machines

**Components Collected**:
- CPU identifier and model
- Motherboard serial number
- Primary disk serial number
- Windows installation ID
- Network adapter MAC address (primary)

**Fingerprint Generation**:
```swift
func generateHardwareFingerprint() -> String {
    let components = [
        getCPUIdentifier(),
        getMotherboardSerial(),
        getDiskSerial(),
        getWindowsID()
    ]
    return SHA256.hash(data: components.joined().data(using: .utf8)!)
}
```

### 4. License File Structure

```json
{
  "license_version": "1.0",
  "application_id": "VA-Calculator-Windows",
  "issued_date": "2025-07-14T21:30:00Z",
  "expiry_date": "2026-07-14T21:30:00Z",
  "license_type": "commercial",
  "authorized_users": [
    "WORKSTATION\\engineer1",
    "DOMAIN\\vibration.analyst"
  ],
  "hardware_binding": {
    "fingerprint": "sha256_hash_of_hardware_components",
    "tolerance": "strict"
  },
  "features": {
    "full_calculator": true,
    "pdf_export": true,
    "advanced_trends": true,
    "gear_analysis": true
  },
  "license_data": {
    "organization": "Example Company",
    "contact": "admin@example.com",
    "user_limit": 5
  },
  "signature": "RSA_SIGNATURE_OF_ABOVE_DATA"
}
```

## Validation Process

### Startup Validation
1. **License File Check**: Verify license file exists and is readable
2. **Signature Validation**: Verify RSA signature using embedded public key
3. **Expiry Check**: Ensure license hasn't expired
4. **User Authorization**: Check current Windows user against whitelist
5. **Hardware Validation**: Verify hardware fingerprint matches
6. **Feature Authorization**: Set available features based on license

### Runtime Validation
- **Periodic Checks**: Re-validate license every 30 minutes
- **Tamper Detection**: Monitor for debugger attachment or memory modification
- **File Integrity**: Verify license file hasn't been modified
- **User Session**: Ensure same authorized user throughout session

## Anti-Tampering Measures

### Code Obfuscation
```swift
// Example obfuscated validation function
private func validateLicenseIntegrity() -> Bool {
    let encodedCheck = Data([0x76, 0x61, 0x6C, 0x69, 0x64]) // "valid"
    let currentUser = getCurrentWindowsUser()
    
    // Obfuscated license validation logic
    return performComplexValidation(user: currentUser, expected: encodedCheck)
}
```

### Integrity Checks
- Application binary checksum verification
- Critical function integrity validation
- Memory protection for license data
- Encrypted string constants

### Environment Detection
- Virtual machine detection
- Debugger attachment detection
- Sandboxed environment identification
- Known analysis tool detection

## License Management

### Creating New Licenses
```bash
# Script: create_license.sh
./Security/KeyGeneration/create_license.sh \
  --user "DOMAIN\\username" \
  --duration "365" \
  --features "full,pdf,trends" \
  --organization "Company Name"
```

### Updating User Whitelist
```bash
# Add user to whitelist
./Security/update_whitelist.sh add "WORKSTATION\\newuser"

# Remove user from whitelist  
./Security/update_whitelist.sh remove "DOMAIN\\olduser"

# List current authorized users
./Security/update_whitelist.sh list
```

### License Revocation
- Remote license revocation via server check (optional)
- Local license invalidation
- Blacklist management for compromised licenses

## Security Best Practices

### Development
1. **Key Security**: Private keys stored in secure, encrypted storage
2. **Code Review**: Security-critical code requires peer review
3. **Testing**: Comprehensive security testing including penetration testing
4. **Logging**: Security events logged for audit purposes

### Deployment
1. **Code Signing**: Application signed with code signing certificate
2. **Secure Distribution**: Licenses distributed through secure channels
3. **User Training**: Instructions for license installation and management
4. **Support**: Clear escalation path for license issues

### Monitoring
1. **License Usage**: Track license usage and violations
2. **Anomaly Detection**: Identify unusual usage patterns
3. **Incident Response**: Procedures for security incidents
4. **Regular Audits**: Periodic security assessments

## Compliance Considerations

- **Data Protection**: No personal data stored beyond Windows username
- **Privacy**: Minimal hardware fingerprinting for identification only
- **Transparency**: Clear license terms and usage restrictions
- **User Rights**: Ability to transfer licenses between authorized machines

## Troubleshooting

### Common Issues
1. **License Not Found**: Check file location and permissions
2. **User Not Authorized**: Verify username in whitelist
3. **Hardware Mismatch**: Re-bind license to new hardware
4. **Signature Invalid**: Regenerate license with current keys
5. **Expired License**: Renew license with new expiry date

### Debug Mode
```swift
// Enable security debug logging
#if DEBUG
SecurityLogger.enableVerboseLogging()
#endif
```

### Support Tools
- License validation utility
- Hardware fingerprint viewer
- User authorization checker
- Security log analyzer