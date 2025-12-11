# Building Zenware Focus

Simple guide to build a clickable `.app` bundle you can use like any normal Mac app.

## Quick Start

```bash
make build    # Build the app
make run      # Launch it
```

That's it! You now have `Zenware Focus.app` ready to double-click.

---

## All Commands

```bash
make build      # Build Zenware Focus.app
make run        # Launch the app
make install    # Build and install to /Applications
make clean      # Remove built files
make rebuild    # Clean and rebuild
make info       # Show app info
make            # Show all commands
```

Or use scripts directly:
```bash
./build-app.sh  # Build the app
./install.sh    # Build + install to /Applications
```

---

## What You Get

**Zenware Focus.app** - A native macOS application that:
- ✅ Double-clicks to open
- ✅ Installs to /Applications
- ✅ Lives in your menu bar
- ✅ Works like any Mac app
- ✅ Optimized & fast (~1 MB)

---

## First Launch

macOS will show a security warning because the app isn't code-signed:

> "Zenware Focus.app can't be opened because it is from an unidentified developer"

**To bypass (one time only):**
1. Right-click (or Control+click) on `Zenware Focus.app`
2. Select **Open**
3. Click **Open** in the dialog

After this, you can open it normally.

---

## Installation

### Option 1: Use Locally
Just double-click `Zenware Focus.app` from your project folder.

### Option 2: Install System-Wide
```bash
make install
# or: cp -r "Zenware Focus.app" /Applications/
```

Now you can:
- Open with Spotlight (⌘+Space → "Zenware Focus")
- Find it in Applications folder
- Pin to Dock

---

## Development Workflow

```bash
# Make code changes
vim Sources/ZenwareFocus/...

# Rebuild
make rebuild

# Test
make run
```

---

## Troubleshooting

### App doesn't show in menu bar
Look at the **top-right** of your screen. The app runs as a menu bar utility (no Dock icon).

### "Build failed"
Check Swift version:
```bash
swift --version  # Should be 5.9 or later
```

### Permission issues
Grant in **System Settings → Privacy & Security**:
- Accessibility (to monitor apps)
- Automation (to control browsers)

### macOS blocks it repeatedly
Remove quarantine attribute:
```bash
xattr -d com.apple.quarantine "Zenware Focus.app"
```

---

## Version Updates

Current version: **0.1.1**

To update, edit `build-app.sh` around line 77 and change:
```xml
<string>0.1.1</string>  <!-- Your new version -->
```

Then rebuild:
```bash
make rebuild
```

---

## Files

- `build-app.sh` - Main build script
- `install.sh` - Install to Applications
- `Makefile` - Convenient commands
- `Zenware Focus.app` - Your built app (not in git)

---

**That's all you need!** 🚀

For app features and usage, see [README.md](README.md)