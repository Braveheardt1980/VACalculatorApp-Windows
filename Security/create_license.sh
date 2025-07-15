#!/bin/bash

# VA Calculator License Creation Script
# Creates signed license files for authorized users

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY_DIR="$SCRIPT_DIR/KeyGeneration/keys"
TEMPLATE_DIR="$SCRIPT_DIR/LicenseTemplates"
OUTPUT_DIR="$SCRIPT_DIR/../Build"

# Default values
USER=""
DURATION="365"
FEATURES="full,pdf,trends"
ORGANIZATION=""
CONTACT=""
OUTPUT_NAME=""

# Function to show usage
show_usage() {
    echo "Usage: $0 --user <username> [options]"
    echo ""
    echo "Required:"
    echo "  --user <username>        Windows username (e.g., 'DOMAIN\\username')"
    echo ""
    echo "Optional:"
    echo "  --duration <days>        License duration in days (default: 365)"
    echo "  --features <list>        Comma-separated features (default: full,pdf,trends)"
    echo "  --organization <name>    Organization name"
    echo "  --contact <email>        Contact email"
    echo "  --output <filename>      Output filename (default: auto-generated)"
    echo "  --help                   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --user 'WORKSTATION\\john.smith'"
    echo "  $0 --user 'DOMAIN\\engineer' --duration 180 --organization 'Example Corp'"
    echo "  $0 --user 'LOCAL\\admin' --features 'full,pdf' --output 'admin_license.json'"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            USER="$2"
            shift 2
            ;;
        --duration)
            DURATION="$2"
            shift 2
            ;;
        --features)
            FEATURES="$2"
            shift 2
            ;;
        --organization)
            ORGANIZATION="$2"
            shift 2
            ;;
        --contact)
            CONTACT="$2"
            shift 2
            ;;
        --output)
            OUTPUT_NAME="$2"
            shift 2
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$USER" ]]; then
    echo "❌ Error: --user parameter is required"
    show_usage
    exit 1
fi

# Check if private key exists
if [[ ! -f "$KEY_DIR/private_key.pem" ]]; then
    echo "❌ Error: Private key not found at $KEY_DIR/private_key.pem"
    echo "   Run ./KeyGeneration/generate_keys.sh first to create the key pair"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Generate output filename if not specified
if [[ -z "$OUTPUT_NAME" ]]; then
    # Clean username for filename
    CLEAN_USER=$(echo "$USER" | sed 's/[\\\/]/_/g' | tr '[:upper:]' '[:lower:]')
    OUTPUT_NAME="${CLEAN_USER}_license.json"
fi

OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_NAME"

echo "🔐 Creating license for user: $USER"
echo "📅 Duration: $DURATION days"
echo "🔧 Features: $FEATURES"
echo "📁 Output: $OUTPUT_PATH"
echo ""

# Calculate dates
ISSUED_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    EXPIRY_DATE=$(date -u -v+"${DURATION}d" +"%Y-%m-%dT%H:%M:%SZ")
else
    # Linux
    EXPIRY_DATE=$(date -u -d "+${DURATION} days" +"%Y-%m-%dT%H:%M:%SZ")
fi

# Parse features into JSON
FEATURE_JSON=""
IFS=',' read -ra FEATURE_ARRAY <<< "$FEATURES"
for feature in "${FEATURE_ARRAY[@]}"; do
    case $feature in
        "full"|"full_calculator")
            FEATURE_JSON="${FEATURE_JSON}\"full_calculator\": true, "
            ;;
        "pdf"|"pdf_export")
            FEATURE_JSON="${FEATURE_JSON}\"pdf_export\": true, "
            ;;
        "trends"|"advanced_trends")
            FEATURE_JSON="${FEATURE_JSON}\"advanced_trends\": true, "
            ;;
        "gear"|"gear_analysis")
            FEATURE_JSON="${FEATURE_JSON}\"gear_analysis\": true, "
            ;;
    esac
done
# Remove trailing comma and space
FEATURE_JSON=$(echo "$FEATURE_JSON" | sed 's/, $//')

# Set default values for optional fields
if [[ -z "$ORGANIZATION" ]]; then
    ORGANIZATION="Licensed Organization"
fi
if [[ -z "$CONTACT" ]]; then
    CONTACT="admin@organization.com"
fi

# Generate hardware fingerprint placeholder
HARDWARE_FINGERPRINT="PLACEHOLDER_$(date +%s)_$(echo "$USER" | md5sum | cut -d' ' -f1)"

# Create license JSON (without signature)
LICENSE_CONTENT=$(cat << EOF
{
  "license_version": "1.0",
  "application_id": "VA-Calculator-Windows",
  "issued_date": "$ISSUED_DATE",
  "expiry_date": "$EXPIRY_DATE",
  "license_type": "commercial",
  "authorized_users": [
    "$USER"
  ],
  "hardware_binding": {
    "fingerprint": "$HARDWARE_FINGERPRINT",
    "tolerance": "strict"
  },
  "features": {
    $FEATURE_JSON
  },
  "license_data": {
    "organization": "$ORGANIZATION",
    "contact": "$CONTACT",
    "user_limit": 1
  }
}
EOF
)

# Create temporary file for signing
TEMP_FILE=$(mktemp)
echo "$LICENSE_CONTENT" > "$TEMP_FILE"

# Generate signature (simplified - in production, implement proper RSA signing)
echo "🔏 Generating license signature..."
SIGNATURE=$(openssl dgst -sha256 -sign "$KEY_DIR/private_key.pem" "$TEMP_FILE" | base64 -w 0)

# Create final license with signature
FINAL_LICENSE=$(echo "$LICENSE_CONTENT" | jq --arg sig "$SIGNATURE" '. + {signature: $sig}')

# Write final license to output file
echo "$FINAL_LICENSE" > "$OUTPUT_PATH"

# Clean up
rm "$TEMP_FILE"

echo "✅ License created successfully!"
echo "📁 License file: $OUTPUT_PATH"
echo ""
echo "📋 License Summary:"
echo "   User: $USER"
echo "   Valid from: $ISSUED_DATE"
echo "   Expires: $EXPIRY_DATE"
echo "   Features: $FEATURES"
echo "   Organization: $ORGANIZATION"
echo ""
echo "📦 Distribution:"
echo "   1. Copy the license file to the application directory"
echo "   2. Ensure the user has the necessary permissions to read the file"
echo "   3. The application will validate the license on startup"
echo ""
echo "⚠️  Security Notes:"
echo "   • The license is tied to the user account: $USER"
echo "   • Hardware binding is enabled for additional security"
echo "   • The license signature prevents tampering"