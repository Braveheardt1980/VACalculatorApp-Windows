# VA Calculator Windows - Deployment Checklist

## Overview

This checklist ensures proper deployment of VA Calculator to end users who **do not have development tools installed**.

## 🎯 End Goal
Create a distribution package that runs on any Windows 10/11 machine **without requiring Swift or development tools**.

---

## Phase 1: Developer Setup (One-Time)

### ✅ Development Environment Setup
- [ ] Install Swift for Windows on **build machine only**
- [ ] Install Visual Studio Build Tools on **build machine only**  
- [ ] Clone VA Calculator Windows project
- [ ] Generate RSA keys for license signing

### ✅ Verify Development Build
```bash
cd VACalculatorApp-Windows
swift package resolve
swift build --configuration debug
swift run VACalculatorApp-Windows
```
- [ ] Application launches successfully
- [ ] UI displays correctly
- [ ] Basic calculations work

---

## Phase 2: Production Build

### ✅ Create Release Build
```bash
# Build with static Swift libraries (critical for standalone deployment)
swift build --configuration release --static-swift-stdlib
```
- [ ] Build completes without errors
- [ ] Executable created at: `.build\release\VACalculatorApp-Windows.exe`
- [ ] File size is reasonable (typically 50-100MB with static libraries)

### ✅ Test Release Build Locally
```bash
# Test the release build
.build\release\VACalculatorApp-Windows.exe
```
- [ ] Application launches from command line
- [ ] All features work correctly
- [ ] Performance is acceptable

---

## Phase 3: Distribution Package Creation

### ✅ Create Distribution Directory
```bash
mkdir Distribution
```

### ✅ Copy Application Files
```bash
# Copy standalone executable
copy .build\release\VACalculatorApp-Windows.exe Distribution\

# Copy application assets
xcopy /E /I Assets Distribution\Assets

# Copy public key for license verification
copy Security\keys\public_key.pem Distribution\
```

### ✅ Verify Distribution Contents
```
Distribution/
├── VACalculatorApp-Windows.exe    ← 50-100MB (includes Swift runtime)
├── public_key.pem                 ← ~1KB
└── Assets/
    └── bearings-master.json       ← ~200KB
```
- [ ] All files present
- [ ] Executable is the static version (large file size)
- [ ] Assets folder contains bearing database

### ✅ Test Distribution Package
**Critical**: Test on a machine **WITHOUT Swift installed**
```bash
cd Distribution
VACalculatorApp-Windows.exe
```
- [ ] Application launches without errors
- [ ] No "DLL not found" or runtime errors
- [ ] All calculations work correctly
- [ ] License validation works (test with valid license)

---

## Phase 4: License Management

### ✅ Generate User Licenses
For each authorized user:

```powershell
# Get user's Windows account name
echo %USERDOMAIN%\%USERNAME%

# Create license (from Security\Scripts directory)
.\Create-License.ps1 -Username "DOMAIN\actualusername" -DurationDays 365
```

### ✅ Verify Licenses
```powershell
.\Verify-License.ps1 -LicenseFile "..\Licenses\va_calculator_user_date.license" -Detailed
```
- [ ] License passes all validation checks
- [ ] User authorization correct
- [ ] Expiry date appropriate
- [ ] Digital signature valid

---

## Phase 5: User Installation Package

### ✅ Create Installation Package

#### Option A: Simple ZIP Distribution
```bash
# Create dated distribution
set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%
7z a "VACalculator_Windows_%timestamp%.zip" Distribution\*
```

#### Option B: Professional Installer (Recommended)
```bash
# Using Inno Setup (download from https://jrsoftware.org/isinfo.php)
# Create VACalculator.iss script (see BUILD_INSTRUCTIONS.md)
# Compile installer
```

### ✅ Package Contents Verification
Distribution should include:
- [ ] `VACalculatorApp-Windows.exe` (standalone)
- [ ] `public_key.pem` 
- [ ] `Assets\bearings-master.json`
- [ ] Installation instructions
- [ ] User setup guide

**Do NOT include:**
- ❌ Source code
- ❌ Private keys
- ❌ Development tools
- ❌ Swift libraries (already in executable)

---

## Phase 6: End-User Testing

### ✅ Clean Machine Test
Test on a machine that has **never had development tools**:

- [ ] Windows 10/11 with no Swift
- [ ] No Visual Studio installed
- [ ] No development environments

### ✅ Installation Test
1. [ ] Extract/install distribution package
2. [ ] Copy user's license file to correct location
3. [ ] Run `VACalculatorApp-Windows.exe`
4. [ ] Verify license validation works
5. [ ] Test all major features
6. [ ] Test calculations against known results

### ✅ User Experience Test
- [ ] Application starts quickly (under 10 seconds)
- [ ] UI is responsive
- [ ] Error messages are user-friendly
- [ ] License errors provide clear guidance

---

## Phase 7: Distribution

### ✅ Secure Distribution
- [ ] Encrypt distribution package if required
- [ ] Create secure download link or email
- [ ] Include installation instructions
- [ ] Provide license file separately

### ✅ User Communication
Send to each user:
- [ ] Distribution package (ZIP or installer)
- [ ] Their specific license file (`va_calculator.license`)
- [ ] Installation instructions
- [ ] Support contact information

### ✅ Documentation Package
Include:
- [ ] SETUP_GUIDE.md (user instructions)
- [ ] Troubleshooting guide
- [ ] License installation guide
- [ ] Support contact information

---

## Phase 8: Validation Checklist

### ✅ Technical Validation
- [ ] Executable is self-contained (no external dependencies)
- [ ] Application works on clean Windows machines
- [ ] License system functions correctly
- [ ] All calculations produce correct results
- [ ] Export functions work properly

### ✅ Security Validation  
- [ ] Private keys remain secure
- [ ] Licenses are properly signed
- [ ] User authorization works correctly
- [ ] Hardware binding functions (if enabled)
- [ ] Application detects tampered licenses

### ✅ User Experience Validation
- [ ] Installation is straightforward
- [ ] Application launches reliably
- [ ] Error messages are helpful
- [ ] Performance is acceptable
- [ ] Features work as expected

---

## Common Issues and Solutions

### "Application won't start"
- **Check**: Is this a clean machine without Swift?
- **Solution**: Ensure you used `--static-swift-stdlib` in build
- **Test**: Run on machine that never had development tools

### "License file not found"
- **Check**: License file location and naming
- **Solution**: Must be named exactly `va_calculator.license`
- **Test**: Verify file is in same directory as .exe

### "User not authorized"
- **Check**: Windows username format in license
- **Solution**: Use exact format from `echo %USERDOMAIN%\%USERNAME%`
- **Test**: Verify on user's actual machine

### "DLL not found" errors
- **Check**: Build used dynamic linking instead of static
- **Solution**: Rebuild with `--static-swift-stdlib` flag
- **Test**: Must work on machine without Swift

---

## Final Checklist

Before declaring deployment ready:

- [ ] ✅ Built with static Swift libraries
- [ ] ✅ Tested on machine without development tools
- [ ] ✅ License system works end-to-end
- [ ] ✅ All calculations verified correct
- [ ] ✅ User documentation complete
- [ ] ✅ Distribution package created
- [ ] ✅ Installation instructions clear
- [ ] ✅ Support process established

**Remember**: End users should only need Windows + your distribution package. If they need to install anything else, the deployment process needs revision.

---

**Critical Success Factor**: The application must run on a "clean" Windows machine that has never had development tools installed. This is the ultimate test of a successful deployment.