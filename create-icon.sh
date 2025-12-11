#!/bin/bash

# Script to create macOS app icon from source image
# Usage: ./create-icon.sh icon-source.png

set -e

echo "🎨 Creating macOS App Icon..."
echo ""

# Check if source image provided
if [ -z "$1" ]; then
    echo "❌ Error: No source image provided"
    echo ""
    echo "Usage: ./create-icon.sh icon-source.png"
    echo ""
    echo "The source image should be at least 1024x1024 pixels"
    exit 1
fi

SOURCE_IMAGE="$1"

# Check if source image exists
if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "❌ Error: Image file not found: $SOURCE_IMAGE"
    exit 1
fi

# Create temporary directory for icon set
ICONSET_DIR="AppIcon.iconset"
rm -rf "$ICONSET_DIR"
mkdir "$ICONSET_DIR"

echo "📐 Generating icon sizes..."

# Generate all required icon sizes for macOS
sips -z 16 16     "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_16x16.png" > /dev/null 2>&1
sips -z 32 32     "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null 2>&1
sips -z 32 32     "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_32x32.png" > /dev/null 2>&1
sips -z 64 64     "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null 2>&1
sips -z 128 128   "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_128x128.png" > /dev/null 2>&1
sips -z 256 256   "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null 2>&1
sips -z 256 256   "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_256x256.png" > /dev/null 2>&1
sips -z 512 512   "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null 2>&1
sips -z 512 512   "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_512x512.png" > /dev/null 2>&1
sips -z 1024 1024 "$SOURCE_IMAGE" --out "$ICONSET_DIR/icon_512x512@2x.png" > /dev/null 2>&1

echo "✅ Icon sizes generated"

# Convert to .icns format
echo "🔄 Converting to .icns format..."
iconutil -c icns "$ICONSET_DIR" -o Resources/AppIcon.icns

if [ $? -eq 0 ]; then
    echo "✅ Icon created: Resources/AppIcon.icns"
    
    # Clean up
    rm -rf "$ICONSET_DIR"
    
    echo ""
    echo "🎉 Success! App icon is ready."
    echo ""
    echo "Next steps:"
    echo "  1. Rebuild your app: make rebuild"
    echo "  2. The icon will appear in Finder and the Dock"
    echo ""
else
    echo "❌ Error creating .icns file"
    rm -rf "$ICONSET_DIR"
    exit 1
fi