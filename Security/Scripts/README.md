# VA Calculator License Management Scripts

This directory contains PowerShell scripts for managing VA Calculator licenses on Windows.

## Scripts Overview

### 1. Generate-Keys.ps1
Generates RSA key pairs for license signing.

**Usage:**
```powershell
# Run as Administrator
.\Generate-Keys.ps1

# Custom key size and output path
.\Generate-Keys.ps1 -KeySize 4096 -OutputPath "C:\VACalc\Keys"
```

**Parameters:**
- `-OutputPath`: Directory to store keys (default: "..\Keys")
- `-KeySize`: RSA key size in bits (default: 2048)

**Outputs:**
- `private_key.pem`: Private key for signing (keep secure!)
- `public_key.pem`: Public key for verification (distribute with app)
- `key_info.json`: Key metadata and fingerprint

### 2. Create-License.ps1
Creates signed license files for authorized users.

**Usage:**
```powershell
# Basic license for domain user
.\Create-License.ps1 -Username "DOMAIN\john.smith"

# License with custom duration and features
.\Create-License.ps1 -Username "WORKSTATION\engineer" -DurationDays 30 -Features @("full_calculator", "pdf_export")

# Corporate license with organization
.\Create-License.ps1 -Username "CORP\admin" -Organization "Acme Corp" -DurationDays 365

# Portable license (no hardware binding)
.\Create-License.ps1 -Username "LAPTOP\user" -NoHardwareBinding
```

**Parameters:**
- `-Username`: Windows account name (required)
- `-DurationDays`: License validity in days (default: 365)
- `-Features`: Array of enabled features (default: all)
- `-Organization`: Organization name (optional)
- `-OutputPath`: Output directory (default: "..\Licenses")
- `-PrivateKeyPath`: Path to private key (default: "..\Keys\private_key.pem")
- `-MachineId`: Specific machine ID for binding (auto-detected if not provided)
- `-NoHardwareBinding`: Create portable license

**Available Features:**
- `full_calculator`: Complete calculation functionality
- `pdf_export`: PDF report generation
- `advanced_trends`: Professional trend recommendations
- `gearbox_analysis`: Gearbox-specific calculations
- `custom_bearings`: Custom bearing database

**Outputs:**
- `va_calculator_[username]_[date].license`: Signed license file
- `va_calculator_[username]_[date]_INSTRUCTIONS.txt`: Installation guide

### 3. Verify-License.ps1
Verifies license file validity and displays information.

**Usage:**
```powershell
# Basic verification
.\Verify-License.ps1 -LicenseFile "..\Licenses\va_calculator_user_20250714.license"

# Detailed information
.\Verify-License.ps1 -LicenseFile "C:\temp\license.license" -Detailed

# Custom public key location
.\Verify-License.ps1 -LicenseFile "license.license" -PublicKeyPath "C:\Keys\public.pem"
```

**Parameters:**
- `-LicenseFile`: Path to license file to verify (required)
- `-PublicKeyPath`: Path to public key (default: "..\Keys\public_key.pem")
- `-Detailed`: Show detailed license information

**Verification Checks:**
- JSON structure validity
- Required fields presence
- Date format and expiry
- User authorization
- Hardware binding (if enabled)
- Digital signature validity

## Setup Instructions

### Initial Setup
1. **Install Prerequisites:**
   ```powershell
   # Check PowerShell version (5.0+ required)
   $PSVersionTable.PSVersion
   
   # Install OpenSSL for Windows
   # Download from: https://slproweb.com/products/Win32OpenSSL.html
   ```

2. **Generate Initial Keys:**
   ```powershell
   # Run as Administrator
   cd Security\Scripts
   .\Generate-Keys.ps1
   ```

3. **Verify Setup:**
   ```powershell
   # Check if keys were created
   dir ..\Keys\*.pem
   
   # Should show:
   # private_key.pem
   # public_key.pem
   ```

### Creating User Licenses

1. **Get User Information:**
   ```powershell
   # On the target user's machine
   echo $env:USERDOMAIN\$env:USERNAME
   ```

2. **Create License:**
   ```powershell
   .\Create-License.ps1 -Username "DOMAIN\actualusername"
   ```

3. **Test License:**
   ```powershell
   .\Verify-License.ps1 -LicenseFile "..\Licenses\va_calculator_DOMAIN_actualusername_20250714.license" -Detailed
   ```

### Distribution Process

1. **Secure Distribution:**
   - Encrypt license files before sending
   - Use secure email or file transfer
   - Include installation instructions

2. **User Installation:**
   - Copy license to application directory
   - Rename to `va_calculator.license`
   - Verify file is not blocked by Windows

3. **Support Process:**
   - Keep record of created licenses
   - Monitor expiry dates
   - Provide verification tools for troubleshooting

## Security Best Practices

### Key Management
- **Private Key Security:**
  - Store in secure, encrypted location
  - Limit access to authorized personnel only
  - Never include in source control
  - Create secure backups

- **Key Rotation:**
  - Generate new keys annually
  - Update public keys in all applications
  - Revoke old keys securely

### License Management
- **Unique Licenses:**
  - Each user should have individual license
  - Include user identification in license
  - Track license distribution

- **Expiry Management:**
  - Monitor license expiration dates
  - Send renewal notices before expiry
  - Automate renewal process if possible

### Incident Response
- **Compromised License:**
  1. Revoke affected license immediately
  2. Generate new license for user
  3. Investigate compromise source
  4. Update security procedures

- **Key Compromise:**
  1. Generate new key pair immediately
  2. Update all applications with new public key
  3. Re-issue all active licenses
  4. Notify all users of security update

## Troubleshooting

### Common Issues

#### "OpenSSL not found"
```powershell
# Install OpenSSL and add to PATH
$env:PATH += ";C:\Program Files\OpenSSL-Win64\bin"
```

#### "Access denied" during key generation
```powershell
# Run PowerShell as Administrator
# Right-click PowerShell → "Run as administrator"
```

#### License verification fails
```powershell
# Check if license file is blocked
Get-Item license.license | Unblock-File

# Verify Windows username format
echo $env:USERDOMAIN\$env:USERNAME
```

#### Hardware binding issues
```powershell
# Check current machine ID
(Get-WmiObject Win32_ComputerSystemProduct).UUID

# Create portable license if hardware changes frequently
.\Create-License.ps1 -Username "user" -NoHardwareBinding
```

### Debug Mode
Enable verbose output for troubleshooting:

```powershell
# Enable PowerShell debug output
$DebugPreference = "Continue"

# Run scripts with additional logging
.\Create-License.ps1 -Username "test" -Verbose
```

## Examples

### Development Environment
```powershell
# Create development license (90 days, no hardware binding)
.\Create-License.ps1 -Username "$env:USERDOMAIN\$env:USERNAME" -DurationDays 90 -NoHardwareBinding -Organization "Development"
```

### Production Distribution
```powershell
# Create production license with all features
.\Create-License.ps1 -Username "CORP\production.user" -DurationDays 365 -Organization "Production Corp"

# Verify before distribution
.\Verify-License.ps1 -LicenseFile "..\Licenses\va_calculator_CORP_production_user_*.license" -Detailed
```

### Temporary Access
```powershell
# Create 30-day trial license
.\Create-License.ps1 -Username "TRIAL\testuser" -DurationDays 30 -Features @("full_calculator") -NoHardwareBinding
```

---

**Security Notice**: Keep private keys secure and never share them. Monitor license usage and report any security concerns immediately.