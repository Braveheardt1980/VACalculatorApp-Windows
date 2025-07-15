# Generate-Keys.ps1
# Generates RSA key pair for VA Calculator license signing
# Run as Administrator

param(
    [string]$OutputPath = "..\Keys",
    [int]$KeySize = 2048
)

Write-Host "VA Calculator - RSA Key Generation" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Error: This script must be run as Administrator" -ForegroundColor Red
    exit 1
}

# Check if OpenSSL is available
$opensslPath = Get-Command openssl -ErrorAction SilentlyContinue
if (-not $opensslPath) {
    Write-Host "Error: OpenSSL not found. Please install OpenSSL for Windows." -ForegroundColor Red
    Write-Host "Download from: https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor Yellow
    exit 1
}

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
    Write-Host "Created directory: $OutputPath" -ForegroundColor Green
}

# Generate timestamp for backup
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Backup existing keys if they exist
if (Test-Path "$OutputPath\private_key.pem") {
    $backupDir = "$OutputPath\Backup_$timestamp"
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Move-Item "$OutputPath\*.pem" $backupDir
    Write-Host "Backed up existing keys to: $backupDir" -ForegroundColor Yellow
}

Write-Host "`nGenerating RSA key pair..." -ForegroundColor Cyan

# Generate private key
$privateKeyPath = "$OutputPath\private_key.pem"
$publicKeyPath = "$OutputPath\public_key.pem"

try {
    # Generate private key
    Write-Host "Generating $KeySize-bit private key..." -ForegroundColor White
    & openssl genrsa -out $privateKeyPath $KeySize 2>$null
    
    if (-not (Test-Path $privateKeyPath)) {
        throw "Failed to generate private key"
    }
    
    # Extract public key
    Write-Host "Extracting public key..." -ForegroundColor White
    & openssl rsa -in $privateKeyPath -pubout -out $publicKeyPath 2>$null
    
    if (-not (Test-Path $publicKeyPath)) {
        throw "Failed to extract public key"
    }
    
    # Set appropriate permissions
    Write-Host "`nSetting file permissions..." -ForegroundColor White
    
    # Private key - restrict access
    $acl = Get-Acl $privateKeyPath
    $acl.SetAccessRuleProtection($true, $false)
    $adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "Administrators", "FullControl", "Allow"
    )
    $currentUserRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        [System.Security.Principal.WindowsIdentity]::GetCurrent().Name, "FullControl", "Allow"
    )
    $acl.SetAccessRule($adminRule)
    $acl.SetAccessRule($currentUserRule)
    Set-Acl $privateKeyPath $acl
    
    # Display key information
    Write-Host "`nKey Generation Complete!" -ForegroundColor Green
    Write-Host "========================" -ForegroundColor Green
    
    # Show key fingerprints
    Write-Host "`nKey Information:" -ForegroundColor Cyan
    $modulus = & openssl rsa -in $privateKeyPath -noout -modulus 2>$null
    $fingerprint = $modulus | Out-String | ForEach-Object { 
        $md5 = [System.Security.Cryptography.MD5]::Create()
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($_)
        $hash = $md5.ComputeHash($bytes)
        [BitConverter]::ToString($hash) -replace '-', ':'
    }
    
    Write-Host "Key Size: $KeySize bits" -ForegroundColor White
    Write-Host "Fingerprint: $fingerprint" -ForegroundColor White
    Write-Host "`nFiles created:" -ForegroundColor White
    Write-Host "  Private Key: $privateKeyPath" -ForegroundColor Yellow
    Write-Host "  Public Key:  $publicKeyPath" -ForegroundColor Green
    
    # Security warnings
    Write-Host "`nIMPORTANT SECURITY NOTES:" -ForegroundColor Red
    Write-Host "1. Keep the private key secure and never share it" -ForegroundColor Yellow
    Write-Host "2. Only distribute the public key with your application" -ForegroundColor Yellow
    Write-Host "3. Backup the private key in a secure location" -ForegroundColor Yellow
    Write-Host "4. If the private key is compromised, generate new keys immediately" -ForegroundColor Yellow
    
    # Create key info file
    $keyInfo = @{
        Generated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        KeySize = $KeySize
        Fingerprint = $fingerprint
        Generator = $env:USERNAME
        Machine = $env:COMPUTERNAME
    }
    
    $keyInfo | ConvertTo-Json | Out-File "$OutputPath\key_info.json"
    
} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nKey generation completed successfully!" -ForegroundColor Green