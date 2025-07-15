# VA Calculator Professional - Windows Setup Guide

## 🚨 NO DEVELOPMENT SOFTWARE REQUIRED

This application is a **standalone Windows executable**. You do NOT need to install:
- ❌ Swift programming language
- ❌ Visual Studio or development tools  
- ❌ Any programming software
- ❌ Additional runtime libraries

Just Windows and the application files!

---

## System Requirements

### Minimum Requirements
- **Operating System**: Windows 10 (64-bit) version 1809 or later
- **Processor**: 2.0 GHz dual-core processor
- **Memory**: 4 GB RAM
- **Storage**: 200 MB available space
- **Display**: 1280×720 resolution

### Recommended Requirements
- **Operating System**: Windows 11 (64-bit)
- **Processor**: 2.5 GHz quad-core processor
- **Memory**: 8 GB RAM
- **Storage**: 500 MB available space
- **Display**: 1920×1080 resolution or higher

## Installation

### Step 1: Verify Your Windows Account
Before installation, you need to know your Windows account name:

1. Open Command Prompt (Win + R, type `cmd`, press Enter)
2. Type the following command:
   ```
   echo %USERDOMAIN%\%USERNAME%
   ```
3. Note this exact account name - you'll need it for license verification

### Step 2: Install VA Calculator

#### Option A: Using Installer (Recommended)
1. Run `VACalculator_Setup.exe` as Administrator
2. Follow the installation wizard:
   - Accept the license agreement
   - Choose installation directory (default: C:\Program Files\VA Calculator)
   - Select Start Menu folder
   - Choose whether to create desktop shortcut
3. Click "Install" and wait for completion

#### Option B: Manual Installation
1. Create directory: `C:\Program Files\VA Calculator`
2. Extract all files from the distribution ZIP to this directory
3. Ensure the following structure:
   ```
   C:\Program Files\VA Calculator\
   ├── VACalculatorApp-Windows.exe
   ├── va_calculator.license
   ├── public_key.pem
   └── Assets\
       └── bearings-master.json
   ```

### Step 3: Install License File

1. **Locate Your License File**
   - You should have received a file named `va_calculator.license`
   - This file is unique to you and tied to your Windows account

2. **Install License**
   - Copy the license file to the VA Calculator installation directory
   - Default location: `C:\Program Files\VA Calculator\va_calculator.license`
   - Alternative locations (if main directory doesn't work):
     - `C:\Users\[YourUsername]\Documents\va_calculator.license`
     - `%APPDATA%\VA Calculator\va_calculator.license`

3. **Verify License Installation**
   - The license file must be named exactly: `va_calculator.license`
   - Check file properties to ensure it's not blocked by Windows:
     - Right-click the license file
     - Select "Properties"
     - If you see "Unblock" checkbox, check it and click "OK"

## First Run

### Launching the Application

1. **From Start Menu**
   - Click Start → VA Calculator → VA Calculator Professional

2. **From Desktop**
   - Double-click the VA Calculator icon (if you created a desktop shortcut)

3. **From Command Line**
   ```
   cd "C:\Program Files\VA Calculator"
   VACalculatorApp-Windows.exe
   ```

### Security Validation

On first launch, the application will:
1. Verify your license file
2. Check your Windows account name
3. Validate hardware fingerprint
4. Enable features based on your license

If validation succeeds, you'll see the main calculator interface.

## Troubleshooting

### Common Issues and Solutions

#### "License file not found"
- **Cause**: License file is missing or in wrong location
- **Solution**: 
  1. Ensure `va_calculator.license` is in the installation directory
  2. Check file name spelling (must be exact)
  3. Try alternative locations listed above

#### "Your Windows account is not authorized"
- **Cause**: Your Windows username doesn't match the license
- **Solution**:
  1. Verify your account name: `echo %USERDOMAIN%\%USERNAME%`
  2. Contact support with your correct account name
  3. You'll receive an updated license file

#### "License has expired"
- **Cause**: Your license validity period has ended
- **Solution**:
  1. Contact support for license renewal
  2. Replace old license file with new one
  3. Restart the application

#### "This license is not valid for this computer"
- **Cause**: License is tied to different hardware
- **Solution**:
  1. Ensure you're using the license created for this specific computer
  2. If you've changed hardware, contact support for a new license
  3. Provide your new hardware details when requesting update

#### Application won't start
- **Cause**: Missing dependencies or permissions
- **Solution**:
  1. Run as Administrator (right-click → Run as administrator)
  2. Install Visual C++ Redistributables:
     - Download from Microsoft: https://aka.ms/vs/17/release/vc_redist.x64.exe
  3. Check Windows Event Viewer for specific errors

#### "Access Denied" errors
- **Cause**: Insufficient permissions
- **Solution**:
  1. Ensure you have read permissions for the installation directory
  2. Run the application as Administrator
  3. Check antivirus/firewall isn't blocking the application

### Advanced Troubleshooting

#### Enable Debug Mode
1. Create a file named `debug.txt` in the installation directory
2. Run the application
3. Check `%APPDATA%\VA Calculator\Logs\` for detailed logs

#### Check Security Status
Run from Command Prompt:
```
cd "C:\Program Files\VA Calculator"
VACalculatorApp-Windows.exe --check-license
```

This will display:
- License status
- User authorization
- Hardware validation
- Feature availability

## Using VA Calculator

### Quick Start Guide

1. **Select Equipment Type**
   - Choose from Motor, Pump, Fan, etc.
   - Some equipment types show "Coming Soon" for future updates

2. **Configure Sensor**
   - Select sensor type (Accelerometer, Velocity, Displacement)
   - Choose mounting method

3. **Enter Operating Speed**
   - Input RPM value
   - Use quick-select buttons for common speeds

4. **Bearing Information**
   - Choose "Yes" if you have specific bearing model numbers
   - Choose "No" to use industry standard calculations

5. **Review and Calculate**
   - Check configuration summary
   - Click "Calculate AP Sets" to generate results

### Saving and Exporting

#### Save Build
- Click "Save Build" after calculation
- Enter descriptive name
- Add optional notes
- Access saved builds from main menu

#### Export Reports
- **HTML Report**: Professional formatted report for web/email
- **Text Report**: Simple format for documentation
- **JSON Data**: Raw data for integration

Export location: `C:\Users\[YourUsername]\Documents\VA Calculator Reports\`

## Best Practices

### License Management
1. **Backup Your License**
   - Keep a secure copy of your license file
   - Store in password-protected location
   - Never share your license file

2. **Regular Validation**
   - Application validates license on each startup
   - Ensure system date/time is correct
   - Don't modify license file contents

### Performance Tips
1. **Close Unnecessary Applications**
   - Frees up system resources
   - Improves calculation speed

2. **Regular Updates**
   - Check for application updates
   - Updates may include performance improvements

### Security Recommendations
1. **Protect Your License**
   - Treat license file as confidential
   - Don't email unencrypted
   - Report if compromised

2. **System Security**
   - Keep Windows updated
   - Use antivirus software
   - Regular backups

## Support

### Getting Help
1. **Documentation**
   - Check this setup guide
   - Review troubleshooting section
   - Read in-app help

2. **Contact Support**
   - Email: support@[your-domain].com
   - Include:
     - Windows version
     - Error messages (exact text or screenshots)
     - Your Windows account name (from `echo %USERDOMAIN%\%USERNAME%`)
     - License expiry date

3. **License Requests**
   - New user setup
   - Hardware changes
   - License renewal
   - Feature upgrades

### Information to Provide
When contacting support, please include:
- Application version (Help → About)
- Windows version (Win + Pause/Break)
- Exact error message
- Steps to reproduce issue
- License expiry date

## Updates and Maintenance

### Checking for Updates
1. The application will notify you when updates are available
2. Download updates from official source only
3. Backup your data before updating

### Update Process
1. Download new version
2. Close VA Calculator
3. Run installer/extract files
4. Your license remains valid after update
5. Saved builds are preserved

### Data Backup
Important files to backup:
- `va_calculator.license` - Your license file
- `%APPDATA%\VA Calculator\*.json` - Saved builds
- `%DOCUMENTS%\VA Calculator Reports\*` - Exported reports

---

**Version**: 1.0  
**Last Updated**: July 2025  
**Copyright**: VA Calculator Professional - All Rights Reserved