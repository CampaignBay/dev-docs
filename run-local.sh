#!/usr/bin/env bash
set -o errexit # Abort if any command fails

# Change to the script's directory for safety
cd "$(dirname "$0")"

echo "🚀 CampaignBay Code Reference Generator - Local Development"
echo "=========================================================="
echo ""
echo "Usage: ./run-local.sh [source-directory]"
echo "  - If source-directory is provided, use that as CampaignBay source"
echo "  - If no argument provided, use ./campaignbay if it exists, otherwise prompt"
echo ""

# Check if PHP is available
if ! command -v php &> /dev/null; then
    echo "❌ PHP is not installed or not in PATH"
    exit 1
fi

# Check if Composer is available
if ! command -v composer &> /dev/null; then
    echo "❌ Composer is not installed or not in PATH"
    exit 1
fi

# Install dependencies if vendor directory doesn't exist
if [ ! -d "vendor" ]; then
    echo "📦 Installing dependencies..."
    composer install
fi

# Determine CampaignBay directory
if [ $# -eq 1 ]; then
    # Use provided source directory
    CAMPAIGNBAY_DIR="$1"
    echo "📁 Using provided source directory: $CAMPAIGNBAY_DIR"
else
    # Prompt user for CampaignBay directory
    echo "📁 Please provide the path to your CampaignBay directory."
    echo "Example: ../campaignbay/app"
    echo ""
    read -p "Enter CampaignBay directory path: " CAMPAIGNBAY_DIR
fi

# Check if directory exists
if [ ! -d "$CAMPAIGNBAY_DIR" ]; then
    echo "❌ CampaignBay plugin directory not found at: $CAMPAIGNBAY_DIR"
    echo "   Please check the path and try again."
    exit 1
fi

echo "📁 Using CampaignBay plugin directory: $CAMPAIGNBAY_DIR"


echo "📁 Copying CampaignBay files..."
mkdir -p campaignbay

# Copy only the directories we want for documentation
cp -r "$CAMPAIGNBAY_DIR" campaignbay/ 2>/dev/null || true


# Generate documentation
echo "🔧 Generating documentation from local CampaignBay source..."
echo ""
# ./deploy.sh --no-download --build-only --source-version 0.0.0 -v
./vendor/bin/phpdoc run --template="data/templates/campaignbay" --sourcecode --defaultpackagename=campaignbay
    php generate-hook-docs.php

echo ""
echo "✅ Documentation generated successfully!"
echo "📁 Output location: ./build/api/"
echo ""
echo "🌐 Starting local web server for CampaignBay Code Reference..."
echo "📁 Serving from: ./build/api"
echo "🌍 URL: http://localhost:8000"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start PHP development server
php -S localhost:8000 -t build/api
