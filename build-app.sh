#!/bin/bash

# Simple build script to create a clickable .app bundle

set -e

echo "🔨 Building Zenware Focus.app..."
echo ""

# Configuration
APP_NAME="Zenware Focus"
PROJECT_DIR="$(pwd)"
BUILD_DIR="$PROJECT_DIR/.build"
APP_BUNDLE="$PROJECT_DIR/$APP_NAME.app"

# Step 1: Clean old app bundle
if [ -d "$APP_BUNDLE" ]; then
    echo "🧹 Cleaning old app bundle..."
    rm -rf "$APP_BUNDLE"
fi

# Step 2: Build the release binary
echo "⚙️  Building release binary..."
swift build -c release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Step 3: Create .app bundle structure
echo "📦 Creating .app bundle..."
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Step 4: Find and copy the binary
echo "📋 Copying binary..."
BINARY_FOUND=false

# Try different possible build locations
if [ -f "$BUILD_DIR/release/ZenwareFocus" ]; then
    cp "$BUILD_DIR/release/ZenwareFocus" "$APP_BUNDLE/Contents/MacOS/ZenwareFocus"
    BINARY_FOUND=true
elif [ -f "$BUILD_DIR/arm64-apple-macosx/release/ZenwareFocus" ]; then
    cp "$BUILD_DIR/arm64-apple-macosx/release/ZenwareFocus" "$APP_BUNDLE/Contents/MacOS/ZenwareFocus"
    BINARY_FOUND=true
elif [ -f "$BUILD_DIR/x86_64-apple-macosx/release/ZenwareFocus" ]; then
    cp "$BUILD_DIR/x86_64-apple-macosx/release/ZenwareFocus" "$APP_BUNDLE/Contents/MacOS/ZenwareFocus"
    BINARY_FOUND=true
fi

if [ "$BINARY_FOUND" = false ]; then
    echo "❌ Could not find built binary!"
    echo "Searched in:"
    echo "  - $BUILD_DIR/release/"
    echo "  - $BUILD_DIR/arm64-apple-macosx/release/"
    echo "  - $BUILD_DIR/x86_64-apple-macosx/release/"
    exit 1
fi

chmod +x "$APP_BUNDLE/Contents/MacOS/ZenwareFocus"

# Step 4.5: Copy app icon if available
if [ -f "Resources/AppIcon.icns" ]; then
    echo "🎨 Adding app icon..."
    cp "Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

# Step 5: Create Info.plist
echo "📝 Creating Info.plist..."
cat > "$APP_BUNDLE/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ZenwareFocus</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.zenware.focus</string>
    <key>CFBundleName</key>
    <string>Zenware Focus</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.1</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAppleEventsUsageDescription</key>
    <string>Zenware Focus needs to control browsers to block distracting websites.</string>
    <key>NSAppleScriptEnabled</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
</dict>
</plist>
EOF

echo ""
echo "✅ Success! Your app is ready:"
echo "   📍 $APP_BUNDLE"
echo ""
echo "🚀 To run it:"
echo "   • Double-click 'Zenware Focus.app' in Finder"
echo "   • Or run: open \"$APP_BUNDLE\""
echo ""
echo "💡 First time opening:"
echo "   If macOS blocks it, right-click → Open → Open"
echo ""
