#!/bin/bash

# Zenware Focus - Installation Script
# Builds and installs the app to /Applications

set -e

echo "📦 Zenware Focus - Installer"
echo ""

# Check if build script exists
if [ ! -f "build-app.sh" ]; then
    echo "❌ Error: build-app.sh not found"
    echo "Please run this script from the Zenware project directory"
    exit 1
fi

# Step 1: Build the app
echo "🔨 Building app..."
./build-app.sh

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo ""

# Step 2: Check if app exists
APP_NAME="Zenware Focus.app"
if [ ! -d "$APP_NAME" ]; then
    echo "❌ Error: $APP_NAME not found"
    exit 1
fi

# Step 3: Install to Applications
echo "📥 Installing to /Applications..."

# Remove old version if it exists
if [ -d "/Applications/$APP_NAME" ]; then
    echo "   Removing old version..."
    rm -rf "/Applications/$APP_NAME"
fi

# Copy new version
cp -r "$APP_NAME" /Applications/

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Installation complete!"
    echo ""
    echo "🚀 Zenware Focus is now installed in your Applications folder"
    echo ""
    echo "To use it:"
    echo "   • Open Spotlight (⌘ + Space)"
    echo "   • Type 'Zenware Focus'"
    echo "   • Press Enter"
    echo ""
    echo "Or find it in: /Applications/Zenware Focus.app"
    echo ""
    echo "💡 First time: If macOS blocks it, right-click → Open → Open"
    echo ""
else
    echo "❌ Installation failed"
    echo "You may need to use sudo:"
    echo "   sudo cp -r \"$APP_NAME\" /Applications/"
    exit 1
fi