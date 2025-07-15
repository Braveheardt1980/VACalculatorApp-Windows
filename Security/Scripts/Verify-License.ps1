# Verify-License.ps1
# Verifies VA Calculator license files
# Can be used for testing and troubleshooting

param(
    [Parameter(Mandatory=$true)]
    [string]$LicenseFile,
    
    [string]$PublicKeyPath = "..\Keys\public_key.pem",
    
    [switch]$Detailed
)

Write-Host "VA Calculator - License Verification Tool" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if files exist
if (-not (Test-Path $LicenseFile)) {
    Write-Host "Error: License file not found: $LicenseFile" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $PublicKeyPath)) {
    Write-Host "Error: Public key not found: $PublicKeyPath" -ForegroundColor Red
    exit 1
}

try {
    # Load and parse license
    Write-Host "`nLoading license file..." -ForegroundColor White
    $licenseContent = Get-Content $LicenseFile -Raw
    $license = $licenseContent | ConvertFrom-Json
    
    Write-Host "✓ License file is valid JSON" -ForegroundColor Green
    
} catch {
    Write-Host "✗ License file is not valid JSON: $_" -ForegroundColor Red
    exit 1
}

# Basic structure validation
Write-Host "`nValidating license structure..." -ForegroundColor White

$requiredFields = @("version", "issued_date", "expiry_date", "authorized_users", "features", "signature")
$missingFields = @()

foreach ($field in $requiredFields) {
    if (-not $license.PSObject.Properties.Name -contains $field) {
        $missingFields += $field
    }
}

if ($missingFields.Count -gt 0) {
    Write-Host "✗ Missing required fields: $($missingFields -join ', ')" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✓ All required fields present" -ForegroundColor Green
}

# Date validation
Write-Host "`nValidating dates..." -ForegroundColor White

try {
    $issuedDate = [DateTime]::Parse($license.issued_date)
    $expiryDate = [DateTime]::Parse($license.expiry_date)
    $currentDate = Get-Date
    
    Write-Host "✓ Dates are valid format" -ForegroundColor Green
    
    if ($currentDate -lt $issuedDate) {
        Write-Host "⚠ License is not yet valid (future issue date)" -ForegroundColor Yellow
    } elseif ($currentDate -gt $expiryDate) {
        Write-Host "✗ License has expired" -ForegroundColor Red
    } else {
        $daysRemaining = ($expiryDate - $currentDate).Days
        Write-Host "✓ License is currently valid ($daysRemaining days remaining)" -ForegroundColor Green
    }
    
} catch {
    Write-Host "✗ Invalid date format: $_" -ForegroundColor Red
}

# User validation
Write-Host "`nValidating user authorization..." -ForegroundColor White

$currentUser = "$env:USERDOMAIN\$env:USERNAME"
if ($license.authorized_users -contains $currentUser) {
    Write-Host "✓ Current user ($currentUser) is authorized" -ForegroundColor Green
} else {
    Write-Host "✗ Current user ($currentUser) is NOT authorized" -ForegroundColor Red
    Write-Host "  Authorized users: $($license.authorized_users -join ', ')" -ForegroundColor Yellow
}

# Hardware binding validation
Write-Host "`nValidating hardware binding..." -ForegroundColor White

if ($license.hardware_binding.binding_enabled) {
    try {
        $currentMachineId = (Get-WmiObject Win32_ComputerSystemProduct).UUID
        if (-not $currentMachineId) {
            $currentMachineId = (Get-WmiObject Win32_BaseBoard).SerialNumber
        }
        
        if ($license.hardware_binding.machine_id -eq $currentMachineId) {
            Write-Host "✓ Hardware binding valid for this machine" -ForegroundColor Green
        } else {
            Write-Host "✗ Hardware binding mismatch" -ForegroundColor Red
            Write-Host "  License machine ID: $($license.hardware_binding.machine_id)" -ForegroundColor Yellow
            Write-Host "  Current machine ID: $currentMachineId" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠ Could not verify hardware binding: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "✓ Hardware binding disabled (license portable)" -ForegroundColor Green
}

# Signature verification
Write-Host "`nVerifying digital signature..." -ForegroundColor White

if (-not $license.signature) {
    Write-Host "✗ No signature found in license" -ForegroundColor Red
} else {
    try {
        # Create temporary files for verification
        $tempLicense = [System.IO.Path]::GetTempFileName()
        $tempSignature = [System.IO.Path]::GetTempFileName()
        
        # Create unsigned license content
        $unsignedLicense = $license.PSObject.Copy()
        $unsignedLicense.signature = ""
        $unsignedContent = $unsignedLicense | ConvertTo-Json -Depth 10
        $unsignedContent | Out-File $tempLicense -Encoding UTF8
        
        # Decode signature
        $signatureBytes = [Convert]::FromBase64String($license.signature)
        [System.IO.File]::WriteAllBytes($tempSignature, $signatureBytes)
        
        # Verify with OpenSSL
        $verifyProcess = Start-Process -FilePath "openssl" -ArgumentList @(
            "dgst", "-sha256", "-verify", $PublicKeyPath, "-signature", $tempSignature, $tempLicense
        ) -Wait -PassThru -NoNewWindow -RedirectStandardOutput NUL -RedirectStandardError NUL
        
        if ($verifyProcess.ExitCode -eq 0) {
            Write-Host "✓ Digital signature is valid" -ForegroundColor Green
        } else {
            Write-Host "✗ Digital signature verification failed" -ForegroundColor Red
        }
        
        # Clean up
        Remove-Item $tempLicense -Force
        Remove-Item $tempSignature -Force
        
    } catch {
        Write-Host "✗ Signature verification error: $_" -ForegroundColor Red
    }
}

# Display detailed information if requested
if ($Detailed) {
    Write-Host "`nDETAILED LICENSE INFORMATION" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    
    Write-Host "`nBasic Information:" -ForegroundColor White
    Write-Host "  Version: $($license.version)"
    Write-Host "  Issued: $($license.issued_date)"
    Write-Host "  Expires: $($license.expiry_date)"
    if ($license.organization) {
        Write-Host "  Organization: $($license.organization)"
    }
    
    Write-Host "`nAuthorized Users:" -ForegroundColor White
    foreach ($user in $license.authorized_users) {
        Write-Host "  - $user"
    }
    
    Write-Host "`nEnabled Features:" -ForegroundColor White
    foreach ($feature in $license.features.PSObject.Properties) {
        $status = if ($feature.Value) { "✓" } else { "✗" }
        $color = if ($feature.Value) { "Green" } else { "Red" }
        Write-Host "  $status $($feature.Name)" -ForegroundColor $color
    }
    
    Write-Host "`nHardware Binding:" -ForegroundColor White
    if ($license.hardware_binding.binding_enabled) {
        Write-Host "  Status: Enabled"
        Write-Host "  Machine ID: $($license.hardware_binding.machine_id)"
    } else {
        Write-Host "  Status: Disabled (portable license)"
    }
    
    Write-Host "`nSignature Information:" -ForegroundColor White
    if ($license.signature) {
        $sigLength = $license.signature.Length
        $sigPreview = $license.signature.Substring(0, [Math]::Min(32, $sigLength))
        Write-Host "  Length: $sigLength characters"
        Write-Host "  Preview: $sigPreview..."
    } else {
        Write-Host "  No signature present"
    }
}

# Overall validation result
Write-Host "`nOVERALL VALIDATION RESULT" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

$currentDate = Get-Date
$isValid = $true
$warnings = @()
$errors = @()

# Check expiry
try {
    $expiryDate = [DateTime]::Parse($license.expiry_date)
    if ($currentDate -gt $expiryDate) {
        $errors += "License has expired"
        $isValid = $false
    }
} catch {
    $errors += "Invalid expiry date"
    $isValid = $false
}

# Check user authorization
$currentUser = "$env:USERDOMAIN\$env:USERNAME"
if ($license.authorized_users -notcontains $currentUser) {
    $errors += "Current user not authorized"
    $isValid = $false
}

# Check hardware binding if enabled
if ($license.hardware_binding.binding_enabled) {
    try {
        $currentMachineId = (Get-WmiObject Win32_ComputerSystemProduct).UUID
        if ($license.hardware_binding.machine_id -ne $currentMachineId) {
            $errors += "Hardware binding mismatch"
            $isValid = $false
        }
    } catch {
        $warnings += "Could not verify hardware binding"
    }
}

# Display result
if ($isValid) {
    Write-Host "✓ LICENSE IS VALID" -ForegroundColor Green
    Write-Host "  The application should run normally with this license." -ForegroundColor White
} else {
    Write-Host "✗ LICENSE IS INVALID" -ForegroundColor Red
    Write-Host "  The application will not run with this license." -ForegroundColor White
}

if ($errors.Count -gt 0) {
    Write-Host "`nErrors:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
}

if ($warnings.Count -gt 0) {
    Write-Host "`nWarnings:" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "  - $warning" -ForegroundColor Yellow
    }
}

Write-Host "`nVerification completed." -ForegroundColor White