#!/bin/bash
set -e

echo "🚀 Building Lambda Layer with Pillow..."

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
TERRAFORM_DIR="$PROJECT_DIR/terraform"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
LAYER_DIR="$TEMP_DIR/python/lib/python3.12/site-packages"

# Create directory structure
mkdir -p "$LAYER_DIR"

# Install Pillow
echo "📦 Installing Pillow..."
pip install -t "$LAYER_DIR" Pillow==10.4.0

# Create zip file
echo "📦 Creating layer zip file..."
cd "$TEMP_DIR"
zip -r pillow_layer.zip python/

# Move to terraform directory
echo "📦 Moving to terraform directory..."
mv pillow_layer.zip "$TERRAFORM_DIR/"

echo "✅ Layer built successfully!"
echo "📍 Location: $TERRAFORM_DIR/pillow_layer.zip"

# Cleanup
rm -rf "$TEMP_DIR"
