# Create-License.ps1
# Creates signed license files for VA Calculator users
# Run as Administrator

param(
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [int]$DurationDays = 365,
    
    [string[]]$Features = @("full_calculator", "pdf_export", "advanced_trends"),
    
    [string]$Organization = "",
    
    [string]$OutputPath = "..\Licenses",
    
    [string]$PrivateKeyPath = "..\Keys\private_key.pem",
    
    [string]$MachineId = "",
    
    [switch]$NoHardwareBinding
)

Write-Host "VA Calculator - License Creation Tool" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Warning: Not running as Administrator. Some operations may fail." -ForegroundColor Yellow
}

# Validate inputs
if (-not (Test-Path $PrivateKeyPath)) {
    Write-Host "Error: Private key not found at: $PrivateKeyPath" -ForegroundColor Red
    Write-Host "Run Generate-Keys.ps1 first to create the key pair." -ForegroundColor Yellow
    exit 1
}

# Normalize username format
if ($Username -notmatch '\\') {
    $Username = "$env:COMPUTERNAME\$Username"
}

Write-Host "`nCreating license for user: $Username" -ForegroundColor White

# Get hardware fingerprint if not provided
if (-not $NoHardwareBinding) {
    if (-not $MachineId) {
        try {
            $MachineId = (Get-WmiObject Win32_ComputerSystemProduct).UUID
            if (-not $MachineId) {
                $MachineId = (Get-WmiObject Win32_BaseBoard).SerialNumber
            }
        } catch {
            Write-Host "Warning: Could not retrieve hardware ID. Creating unbound license." -ForegroundColor Yellow
            $NoHardwareBinding = $true
        }
    }
}

# Calculate expiry date
$issuedDate = Get-Date
$expiryDate = $issuedDate.AddDays($DurationDays)

# Create license object
$license = [ordered]@{
    version = "1.0"
    issued_date = $issuedDate.ToString("yyyy-MM-ddTHH:mm:ssZ")
    expiry_date = $expiryDate.ToString("yyyy-MM-ddTHH:mm:ssZ")
    authorized_users = @($Username)
    organization = $Organization
    features = [ordered]@{}
    hardware_binding = [ordered]@{}
    signature = ""
}

# Set features
$validFeatures = @("full_calculator", "pdf_export", "advanced_trends", "gearbox_analysis", "custom_bearings")
foreach ($feature in $validFeatures) {
    $license.features[$feature] = $Features -contains $feature
}

# Set hardware binding
if (-not $NoHardwareBinding -and $MachineId) {
    $license.hardware_binding["machine_id"] = $MachineId
    $license.hardware_binding["binding_enabled"] = $true
} else {
    $license.hardware_binding["binding_enabled"] = $false
}

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# Generate filename
$safeUsername = $Username -replace '\\', '_' -replace '[<>:"/|?*]', '_'
$filename = "va_calculator_${safeUsername}_$(Get-Date -Format 'yyyyMMdd').license"
$licenseFile = Join-Path $OutputPath $filename

# Convert to JSON
$jsonContent = $license | ConvertTo-Json -Depth 10

# Create temporary unsigned license file
$tempFile = [System.IO.Path]::GetTempFileName()
$jsonContent | Out-File $tempFile -Encoding UTF8

try {
    # Sign the license
    Write-Host "Signing license..." -ForegroundColor White
    
    $signatureFile = [System.IO.Path]::GetTempFileName()
    
    # Use OpenSSL to create signature
    $opensslProcess = Start-Process -FilePath "openssl" -ArgumentList @(
        "dgst", "-sha256", "-sign", $PrivateKeyPath, "-out", $signatureFile, $tempFile
    ) -Wait -PassThru -NoNewWindow
    
    if ($opensslProcess.ExitCode -ne 0) {
        throw "OpenSSL signing failed"
    }
    
    # Read signature and encode as base64
    $signatureBytes = [System.IO.File]::ReadAllBytes($signatureFile)
    $signatureBase64 = [Convert]::ToBase64String($signatureBytes)
    
    # Update license with signature
    $license.signature = $signatureBase64
    
    # Create final signed license
    $signedJson = $license | ConvertTo-Json -Depth 10
    $signedJson | Out-File $licenseFile -Encoding UTF8
    
    # Clean up temp files
    Remove-Item $tempFile -Force
    Remove-Item $signatureFile -Force
    
} catch {
    Write-Host "Error creating license signature: $_" -ForegroundColor Red
    exit 1
}

# Display license information
Write-Host "`nLicense Created Successfully!" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

Write-Host "`nLicense Details:" -ForegroundColor Cyan
Write-Host "  User: $Username" -ForegroundColor White
Write-Host "  Organization: $(if($Organization) {$Organization} else {'N/A'})" -ForegroundColor White
Write-Host "  Issued: $($issuedDate.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor White
Write-Host "  Expires: $($expiryDate.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor White
Write-Host "  Duration: $DurationDays days" -ForegroundColor White

Write-Host "`nEnabled Features:" -ForegroundColor Cyan
foreach ($feature in $license.features.Keys) {
    $status = if ($license.features[$feature]) { "✓" } else { "✗" }
    $color = if ($license.features[$feature]) { "Green" } else { "Red" }
    Write-Host "  $status $feature" -ForegroundColor $color
}

Write-Host "`nHardware Binding:" -ForegroundColor Cyan
if ($license.hardware_binding.binding_enabled) {
    Write-Host "  ✓ Enabled - Tied to machine: $($license.hardware_binding.machine_id)" -ForegroundColor Green
} else {
    Write-Host "  ✗ Disabled - Can run on any machine" -ForegroundColor Yellow
}

Write-Host "`nFile Location:" -ForegroundColor Cyan
Write-Host "  $licenseFile" -ForegroundColor Yellow

# Create installation instructions
$instructionsFile = $licenseFile -replace '\.license$', '_INSTRUCTIONS.txt'
$instructions = @"
VA Calculator License Installation Instructions
=============================================

License File: $filename
Created: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
For User: $Username

INSTALLATION STEPS:
1. Copy the license file to one of these locations:
   - Same directory as VACalculatorApp-Windows.exe
   - C:\Users\[Username]\Documents\va_calculator.license
   - %APPDATA%\VA Calculator\va_calculator.license

2. Rename the file to exactly: va_calculator.license

3. Ensure the file is not blocked by Windows:
   - Right-click the file → Properties
   - If you see "Unblock" checkbox, check it and click OK

4. Run VACalculatorApp-Windows.exe

TROUBLESHOOTING:
- If you get "User not authorized" error, verify your Windows username:
  Command: echo %USERDOMAIN%\%USERNAME%
  Expected: $Username

- If you get "Hardware mismatch" error, the license is tied to a different computer
  Contact support for a new license

LICENSE DETAILS:
- Valid from: $($issuedDate.ToString('yyyy-MM-dd'))
- Valid until: $($expiryDate.ToString('yyyy-MM-dd'))
- Hardware binding: $(if($license.hardware_binding.binding_enabled) {'Enabled'} else {'Disabled'})

SUPPORT:
Email: support@[your-domain].com
Include: Windows username, error messages, license expiry date
"@

$instructions | Out-File $instructionsFile -Encoding UTF8

Write-Host "`nInstallation instructions created: $instructionsFile" -ForegroundColor Green

# Verification
Write-Host "`nVerifying license file..." -ForegroundColor White
try {
    $verifyContent = Get-Content $licenseFile -Raw | ConvertFrom-Json
    if ($verifyContent.signature -and $verifyContent.authorized_users -contains $Username) {
        Write-Host "✓ License file verified successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ License file verification failed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ License file is not valid JSON" -ForegroundColor Red
}

Write-Host "`nLicense creation completed!" -ForegroundColor Green
Write-Host "`nIMPORTANT:" -ForegroundColor Red
Write-Host "- Distribute the license file securely (encrypted email)" -ForegroundColor Yellow
Write-Host "- Include the installation instructions" -ForegroundColor Yellow
Write-Host "- Keep a record of created licenses for support purposes" -ForegroundColor Yellow