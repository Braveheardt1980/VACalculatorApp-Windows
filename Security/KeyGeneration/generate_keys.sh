#!/bin/bash

# VA Calculator License Key Generation Script
# Generates RSA key pair for license signing and verification

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY_DIR="$SCRIPT_DIR/keys"

# Create keys directory if it doesn't exist
mkdir -p "$KEY_DIR"

echo "🔐 Generating RSA key pair for VA Calculator license system..."

# Generate 2048-bit RSA private key
echo "📝 Generating private key..."
openssl genrsa -out "$KEY_DIR/private_key.pem" 2048

# Extract public key
echo "📝 Extracting public key..."
openssl rsa -in "$KEY_DIR/private_key.pem" -outform PEM -pubout -out "$KEY_DIR/public_key.pem"

# Set secure permissions
chmod 600 "$KEY_DIR/private_key.pem"
chmod 644 "$KEY_DIR/public_key.pem"

echo "✅ RSA key pair generated successfully!"
echo "📁 Private key: $KEY_DIR/private_key.pem"
echo "📁 Public key: $KEY_DIR/public_key.pem"
echo ""
echo "⚠️  IMPORTANT SECURITY NOTES:"
echo "   • Keep the private key secure and never share it"
echo "   • The private key is used to sign licenses"
echo "   • The public key will be embedded in the application"
echo "   • Back up the private key in a secure location"
echo ""

# Generate a sample license template
echo "📝 Generating sample license template..."
cat > "$SCRIPT_DIR/../LicenseTemplates/license_template.json" << 'EOF'
{
  "license_version": "1.0",
  "application_id": "VA-Calculator-Windows",
  "issued_date": "2025-07-14T21:30:00Z",
  "expiry_date": "2026-07-14T21:30:00Z",
  "license_type": "commercial",
  "authorized_users": [
    "WORKSTATION\\username",
    "DOMAIN\\engineer"
  ],
  "hardware_binding": {
    "fingerprint": "HARDWARE_FINGERPRINT_HASH",
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
  "signature": "RSA_SIGNATURE_PLACEHOLDER"
}
EOF

echo "📄 License template created: $SCRIPT_DIR/../LicenseTemplates/license_template.json"
echo ""
echo "🚀 Next steps:"
echo "   1. Embed the public key in your application"
echo "   2. Use create_license.sh to generate signed licenses"
echo "   3. Distribute licenses to authorized users"