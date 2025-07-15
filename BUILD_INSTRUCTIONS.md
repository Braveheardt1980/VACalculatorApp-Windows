# VA Calculator Windows - Build Instructions

## 🚨 IMPORTANT: Development vs End-User Requirements

### **For DEVELOPERS (You) - Building the Application:**
You need Swift and development tools to **compile** the application once.

### **For END USERS - Running the Application:**
End users only need:
- Windows 10/11 (64-bit)
- The standalone `.exe` file you build
- **NO Swift installation required**
- **NO development tools required**

The build process creates a **self-contained executable** that includes all dependencies.

---

## Developer Prerequisites (Build Machine Only)

### 1. Install Swift for Windows
1. Download Swift for Windows from: https://www.swift.org/download/
2. Choose the latest stable release (5.10 or later)
3. Run the installer with administrator privileges
4. Add Swift to your PATH during installation

### 2. Install Visual Studio Build Tools
1. Download Visual Studio Build Tools from: https://visualstudio.microsoft.com/downloads/
2. Install with these workloads:
   - Desktop development with C++
   - Windows 10 SDK (latest version)
3. Restart after installation

### 3. Install Git for Windows
1. Download from: https://git-scm.com/download/win
2. Use default settings during installation

## Building the Application

### 1. Clone and Setup
```bash
# Open Command Prompt or PowerShell
cd C:\Projects
git clone [your-repo-url] VACalculatorApp-Windows
cd VACalculatorApp-Windows
```

### 2. Install Dependencies
```bash
# Resolve Swift package dependencies
swift package resolve

# This will download:
# - SwiftCrossUI
# - CryptoSwift
# - Swift Crypto
```

### 3. Development Build
```bash
# Build debug version
swift build --configuration debug

# Run the application
swift run VACalculatorApp-Windows
```

### 4. Release Build
```bash
# Build optimized release version
swift build --configuration release --static-swift-stdlib

# Output location: .build\release\VACalculatorApp-Windows.exe
```

### 5. Create Standalone Distribution Package
```bash
# Create distribution directory
mkdir Distribution

# Copy standalone executable (contains ALL Swift runtime libraries)
copy .build\release\VACalculatorApp-Windows.exe Distribution\

# Copy required application assets
xcopy /E /I Assets Distribution\Assets

# Copy public key for license verification
copy Security\keys\public_key.pem Distribution\

# The Distribution folder now contains everything end users need!
# No Swift installation required on target machines
```

### 6. What Gets Distributed to End Users
The `Distribution` folder contains:
```
Distribution/
├── VACalculatorApp-Windows.exe    ← Self-contained executable (includes Swift runtime)
├── public_key.pem                 ← License verification key
├── Assets/                        ← Application resources
│   └── bearings-master.json       ← Bearing database
└── [User receives their va_calculator.license file separately]
```

**Key Point**: The `.exe` file contains ALL required libraries thanks to `--static-swift-stdlib`

## License System Setup

### 1. Generate RSA Keys (One-time)
```bash
# Generate key pair for license signing
cd Security\KeyGeneration

# Using OpenSSL (install from https://slproweb.com/products/Win32OpenSSL.html)
openssl genrsa -out private_key.pem 2048
openssl rsa -in private_key.pem -pubout -out public_key.pem

# Copy public key to distribution
copy public_key.pem ..\..\Distribution\
```

### 2. Create User Licenses
```bash
# Create PowerShell script: create_license.ps1
$user = "DOMAIN\username"
$expiry = (Get-Date).AddYears(1).ToString("yyyy-MM-dd")
$hardware = Get-WmiObject Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID

$license = @{
    version = "1.0"
    issued_date = (Get-Date).ToString("yyyy-MM-dd")
    expiry_date = $expiry
    authorized_users = @($user)
    features = @{
        full_calculator = $true
        pdf_export = $true
        advanced_trends = $true
    }
    hardware_binding = @{
        machine_id = $hardware
    }
}

$json = $license | ConvertTo-Json -Depth 10
$json | Out-File "va_calculator.license" -Encoding UTF8

# Sign the license file (requires OpenSSL)
openssl dgst -sha256 -sign private_key.pem -out license.sig va_calculator.license
```

## Testing

### 1. Unit Tests
```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter VACalculatorTests.CalculationTests
```

### 2. Security Testing
```bash
# Test license validation
swift test --filter SecurityTests

# Test with invalid license
copy Tests\TestLicenses\expired.license Distribution\va_calculator.license
.\Distribution\VACalculatorApp-Windows.exe
# Should show "License expired" error

# Test with valid license
copy Tests\TestLicenses\valid.license Distribution\va_calculator.license
.\Distribution\VACalculatorApp-Windows.exe
# Should run normally
```

## Troubleshooting

### Common Build Issues

#### Swift Not Found
```bash
# Verify Swift installation
swift --version
# Should show: Swift version 5.10.x

# If not found, add to PATH:
set PATH=%PATH%;C:\Library\Developer\Toolchains\unknown-Asserts-development.xctoolchain\usr\bin
```

#### Missing Dependencies
```bash
# Clear package cache
swift package purge-cache

# Re-resolve dependencies
swift package resolve
```

#### Linker Errors
```bash
# Ensure Visual Studio Build Tools are installed
# Run from Developer Command Prompt:
cl.exe
# Should show Microsoft C/C++ compiler version

# If missing, reinstall VS Build Tools
```

### Runtime Issues

#### Application Won't Start
1. Check for missing DLLs:
   ```bash
   # Use Dependency Walker or similar tool
   depends.exe VACalculatorApp-Windows.exe
   ```

2. Verify Swift runtime:
   ```bash
   # Copy Swift runtime libraries
   xcopy /E /I "C:\Library\Swift-development\bin" Distribution\
   ```

#### License Validation Fails
1. Verify license file location:
   - Same directory as .exe
   - Named exactly: `va_calculator.license`

2. Check Windows username:
   ```bash
   echo %USERDOMAIN%\%USERNAME%
   ```

3. Verify file permissions:
   - Right-click → Properties → Security
   - Ensure read access

## Creating Installer

### Using Inno Setup
1. Download Inno Setup from: https://jrsoftware.org/isinfo.php
2. Create installer script: `VACalculator.iss`

```ini
[Setup]
AppName=VA Calculator Professional
AppVersion=1.0
DefaultDirName={pf}\VA Calculator
DefaultGroupName=VA Calculator
OutputDir=Installers
OutputBaseFilename=VACalculator_Setup
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=admin

[Files]
Source: "Distribution\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\VA Calculator"; Filename: "{app}\VACalculatorApp-Windows.exe"
Name: "{group}\Uninstall VA Calculator"; Filename: "{uninstallexe}"
Name: "{commondesktop}\VA Calculator"; Filename: "{app}\VACalculatorApp-Windows.exe"

[Run]
Filename: "{app}\VACalculatorApp-Windows.exe"; Description: "Launch VA Calculator"; Flags: nowait postinstall skipifsilent
```

3. Compile installer:
   - Open .iss file in Inno Setup
   - Click Build → Compile
   - Output: `Installers\VACalculator_Setup.exe`

## Distribution Checklist

- [ ] Build release version with optimizations
- [ ] Test on clean Windows 10/11 system
- [ ] Generate unique license for each user
- [ ] Include license file with distribution
- [ ] Document user's Windows account name
- [ ] Provide installation instructions
- [ ] Include support contact information

## Performance Optimization

### Build Flags
```bash
# Maximum optimization
swift build -c release -Xswiftc -O -Xswiftc -whole-module-optimization

# Strip debug symbols
strip .build\release\VACalculatorApp-Windows.exe

# Compress executable
upx --best .build\release\VACalculatorApp-Windows.exe
```

### Runtime Performance
1. Enable hardware acceleration:
   ```swift
   // In main.swift
   Environment.set("SWIFT_ENABLE_ACCELERATION", "1")
   ```

2. Optimize for specific CPU:
   ```bash
   swift build -c release -Xswiftc -target-cpu=native
   ```

## Security Hardening

### Code Signing
```bash
# Sign executable with certificate
signtool sign /f "certificate.pfx" /p password /t http://timestamp.digicert.com VACalculatorApp-Windows.exe
```

### Anti-Tampering
1. Enable compiler protections:
   ```bash
   swift build -c release -Xswiftc -enforce-exclusivity=checked
   ```

2. Add integrity checks in code:
   ```swift
   // Already implemented in SecurityManager.swift
   ```

---

**Support**: For build issues, check the troubleshooting section or contact support.  
**Updates**: Check for SwiftCrossUI updates regularly for bug fixes and improvements.