# Windows Deployment Guide

## Overview

This guide covers the deployment process for the VA Calculator App Windows edition, including license management and user setup.

## Prerequisites

### Development Environment
- Swift 5.10+ for Windows
- SwiftCrossUI framework
- OpenSSL for license management
- Windows 10/11 (x64)

### Runtime Requirements (End Users)
- Windows 10/11 (x64)
- Valid license file
- User account listed in authorized users

## Build Process

### 1. Development Build
```bash
# Navigate to project directory
cd VACalculatorApp-Windows

# Resolve dependencies
swift package resolve

# Build for development
swift build --configuration debug

# Run application
swift run VACalculatorApp-Windows
```

### 2. Production Build
```bash
# Build optimized release
swift build --configuration release --static-swift-stdlib

# The executable will be in: .build/release/VACalculatorApp-Windows.exe
```

### 3. Creating Distribution Package
```bash
# Create distribution directory
mkdir VACalculator-Distribution

# Copy executable
cp .build/release/VACalculatorApp-Windows.exe VACalculator-Distribution/

# Copy required assets
cp -r Assets/* VACalculator-Distribution/

# Create sample license (replace with actual license)
./Security/create_license.sh --user "DOMAIN\\username" --output VACalculator-Distribution/va_calculator.license
```

## License Management

### 1. Generate Key Pair (One-time Setup)
```bash
# Generate RSA keys for license signing
./Security/KeyGeneration/generate_keys.sh
```

### 2. Create User Licenses
```bash
# Create license for specific user
./Security/create_license.sh --user "WORKSTATION\\john.smith" --duration 365

# Create license with specific features
./Security/create_license.sh --user "DOMAIN\\engineer" --features "full,pdf,trends" --organization "Example Corp"

# Create temporary license (30 days)
./Security/create_license.sh --user "TEMP\\testuser" --duration 30 --features "full"
```

### 3. License Distribution
1. **Secure Transfer**: Send license files through secure channels (encrypted email, secure file transfer)
2. **Installation Instructions**: Provide users with clear installation steps
3. **Support Contact**: Include support information for license issues

## User Installation

### 1. Application Installation
1. Copy `VACalculatorApp-Windows.exe` to desired directory (e.g., `C:\Program Files\VA Calculator\`)
2. Copy `Assets` folder to the same directory
3. Ensure user has read/execute permissions

### 2. License Installation
1. Copy the provided `.license` file to one of these locations:
   - Same directory as the executable
   - User's Documents folder
   - `%APPDATA%\VA Calculator\`
2. Verify the license file is named `va_calculator.license`

### 3. First Run
1. Run `VACalculatorApp-Windows.exe`
2. The application will validate the license on startup
3. If validation succeeds, the main calculator interface will appear
4. If validation fails, an error message will explain the issue

## Security Considerations

### Key Management
- **Private Key Security**: Store the private key in a secure, encrypted location
- **Key Backup**: Maintain secure backups of the private key
- **Access Control**: Limit access to key generation tools to authorized personnel only

### License Security
- **Unique Licenses**: Each user should have their own license file
- **Hardware Binding**: Licenses are tied to specific computers for security
- **Expiration Management**: Monitor license expiration dates and renew as needed

### Distribution Security
- **Secure Channels**: Always distribute licenses through secure, encrypted channels
- **Verification**: Verify recipient identity before distributing licenses
- **Audit Trail**: Maintain records of license distribution for security auditing

## Troubleshooting

### Common Installation Issues

#### License Not Found
**Error**: "License file not found"
**Solution**: 
1. Verify license file is named `va_calculator.license`
2. Check file is in the correct location
3. Ensure user has read permissions

#### User Not Authorized
**Error**: "Your Windows account is not authorized"
**Solution**:
1. Verify username matches license exactly (including domain)
2. Check Windows account name format (DOMAIN\username)
3. Create new license with correct username if needed

#### License Expired
**Error**: "Your license has expired"
**Solution**:
1. Check license expiry date
2. Create new license with extended expiry
3. Replace old license file with new one

#### Hardware Mismatch
**Error**: "This license is not valid for this computer"
**Solution**:
1. Verify user is on the correct computer
2. Create new license bound to current hardware
3. Check hardware fingerprinting settings

### Debug Mode

Enable debug mode for troubleshooting:
```bash
# Build with debug information
swift build --configuration debug

# Run with verbose security logging
SECURITY_DEBUG=1 ./VACalculatorApp-Windows.exe
```

### Log Files

Application logs are written to:
- Windows: `%APPDATA%\VA Calculator\Logs\`
- Development: Console output

## Support Procedures

### User Support
1. **License Issues**: Check license validity, expiry, and user authorization
2. **Installation Problems**: Verify file permissions and locations
3. **Performance Issues**: Check system requirements and resource usage

### Administrator Tasks
1. **User Management**: Add/remove users from licenses
2. **License Renewal**: Create new licenses before expiry
3. **Security Monitoring**: Review access logs and security events

### Emergency Procedures
1. **Compromised License**: Revoke and replace compromised licenses immediately
2. **Security Breach**: Review all distributed licenses and regenerate keys if necessary
3. **System Recovery**: Restore from secure backups of keys and license templates

## Maintenance

### Regular Tasks
- **License Monitoring**: Track license expiration dates
- **User Auditing**: Verify authorized users are still active
- **Security Updates**: Apply security patches and updates
- **Backup Verification**: Test backup and recovery procedures

### Quarterly Reviews
- **Access Review**: Audit user access and permissions
- **Security Assessment**: Review security controls and measures
- **Process Improvement**: Update procedures based on lessons learned

---

**Note**: This deployment guide should be customized for your specific organizational requirements and security policies.