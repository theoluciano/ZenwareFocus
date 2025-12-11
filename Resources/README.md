# App Icon Setup

## Quick Setup

1. Save your icon image as `icon.png` in this directory (1024x1024 or larger recommended)

2. Run the icon creation script:
   ```bash
   ./create-icon.sh Resources/icon.png
   ```

3. Rebuild your app:
   ```bash
   make rebuild
   ```

Your app will now have the custom icon! 🎉

## What This Does

The `create-icon.sh` script:
- Takes your source image (any size, but 1024x1024 recommended)
- Generates all required sizes for macOS (16px to 1024px)
- Creates `AppIcon.icns` in the Resources folder
- The build script automatically includes it in your app bundle

## Icon Appears In:
- ✅ Finder (when viewing the .app)
- ✅ Dock (when app is running)
- ✅ Applications folder
- ✅ Spotlight search results
- ✅ Command+Tab app switcher

## Troubleshooting

**Icon doesn't appear after rebuild:**
```bash
# Clear icon cache
sudo rm -rf /Library/Caches/com.apple.iconservices.store
killall Dock
killall Finder
```

**"sips: Unable to open file" error:**
Make sure your image file exists and is a valid PNG or JPEG.

**Icon looks blurry:**
Use a larger source image (at least 1024x1024 pixels).
