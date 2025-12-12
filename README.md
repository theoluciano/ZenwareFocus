# Zenware Focus

A powerful focus and productivity app for macOS that helps you stay in flow by blocking distracting apps and websites during focused work sessions.

> **Latest Update (v0.1.1)**: Menu bar timer, Arc browser support, improved UI with fixed-width countdown display, and preset sheet bug fixes.

## Features

### ✨ Core Features
- **Goal-Based Focus Sessions** - Set a clear goal and duration for each focus session
- **Menu Bar Timer** - Live countdown displayed in your menu bar during active sessions
- **App Blocking** - Automatically block distracting applications during your session
- **Website Blocking** - Block distracting websites across Safari, Chrome, Arc, and Firefox
- **Flexible Duration** - Focus for 5 minutes or an entire workday
- **Block Categories** - Quick presets for common distraction categories:
  - Social Media (Twitter, Facebook, Instagram, TikTok, etc.)
  - Shopping (Amazon, eBay, Etsy, etc.)
  - Entertainment (YouTube, Netflix, Spotify, etc.)
  - Gaming (Steam, Discord, Epic Games, etc.)
  - Messaging (Slack, WhatsApp, Telegram, etc.)
  - News (CNN, BBC, NY Times, etc.)

### 🎯 Advanced Features
- **Custom App Blocking** - Select specific apps to block with searchable app picker
- **Snooze Functionality** - Temporarily access blocked apps/websites for 3 minutes
- **Pause/Resume** - Pause your session when needed without losing progress
- **Custom Presets** - Save your favorite focus configurations with 4 built-in defaults
- **Session History** - Track and manage your completed focus sessions
- **Menu Bar Integration** - Quick access with live timer display
- **Session Extension** - Add more time to an active session

## Requirements

- macOS 13.0 (Ventura) or later
- Swift 5.9 or later

## Installation

### Quick Build (Recommended)

Build a clickable `.app` bundle:

```bash
make build
make run
```

This creates **`Zenware Focus.app`** that you can double-click to open.

See **[RELEASE.md](RELEASE.md)** for all build commands and troubleshooting.

### Alternative: Run from Command Line

```bash
swift run
```

## Project Structure

```
Zenware/
├── Package.swift              # Swift Package Manager manifest
├── Makefile                   # Build commands
├── build-app.sh              # App bundle creation script
├── Sources/
│   └── ZenwareFocus/
│       ├── ZenwareFocusApp.swift     # Main app entry point
│       ├── Models/
│       │   ├── FocusSession.swift    # Session data model
│       │   ├── FocusManager.swift    # Session state management
│       │   ├── FocusPreset.swift     # Preset configurations
│       │   └── BlockCategory.swift   # Website/app categories
│       ├── Views/
│       │   ├── FocusView.swift           # Main UI
│       │   ├── StartSession/             # Session start views
│       │   ├── ActiveSession/            # Active session views
│       │   ├── Presets/                  # Preset management
│       │   ├── History/                  # Session history
│       │   └── Shared/                   # Shared components
│       └── Services/
│           ├── AppBlockerService.swift       # App blocking logic
│           └── WebsiteBlockerService.swift   # Website blocking (Safari, Chrome, Arc)
└── Resources/
    └── AppIcon.icns          # App icon
```

## Usage

### Starting a Focus Session

1. Click the Zenware Focus icon in your menu bar
2. Enter your goal (e.g., "Finish project proposal")
3. Select a duration (5 min, 25 min, 1 hour, etc.)
4. Choose categories of apps/websites to block or select specific apps
5. Click "Start Focus Session"
6. Watch the countdown timer appear in your menu bar

### Using Presets

1. Navigate to the "Presets" tab
2. Choose from default presets:
   - **Deep Work** - 2 hours with maximum blocking
   - **Quick Focus** - 25 minutes for quick tasks
   - **Study Session** - 1 hour for focused learning
   - **Meeting Mode** - 30 minutes for meetings
3. Enter your goal and start

### During a Session

- **View Progress** - See your remaining time in the menu bar and circular timer
- **Pause** - Temporarily pause your session
- **Resume** - Continue your paused session
- **Extend** - Add 5 more minutes to your session
- **Stop** - End the session early (timer disappears from menu bar)

### Custom App Blocking

1. In the "Block Specific Apps" section, click "Select apps to block"
2. Search or browse installed applications
3. Select apps to block during your session
4. Selected apps will be automatically hidden when you start

### Snoozing Blocked Items

If you try to open a blocked app, you'll see an alert with options:
- **OK** - Keep the app blocked
- **Snooze for 3 minutes** - Temporarily allow access

## How It Works

### Menu Bar Timer
- Displays live countdown during active sessions (e.g., `25:30` or `1:30:22`)
- Uses monospaced digits for stable, non-jumping display
- Automatically appears when session starts and disappears when stopped
- Fixed-width design prevents menu bar items from shifting

### App Blocking
The app monitors running applications and automatically hides blocked apps during your focus session. It uses macOS's `NSWorkspace` API to detect app launches and manage blocked applications. Apps are restored when the session ends.

### Website Blocking
Website blocking is implemented using AppleScript to monitor browser tabs every 2 seconds:
- **Safari** - Full tab monitoring and blocking
- **Chrome** - Full tab monitoring and blocking
- **Arc** - Full tab monitoring and blocking
- **Firefox** - Limited support (browser limitations)

When a blocked website is detected, the tab is redirected to a blank page.

## Permissions

Zenware Focus requires the following permissions:
- **Accessibility Access** - To monitor and control running applications
- **Automation** - To control browsers (Safari, Chrome, Arc, Firefox) for website blocking

You'll be prompted to grant these permissions when you first run the app. Grant access in **System Settings → Privacy & Security → Automation**.

## Development

### Build Commands

```bash
make build      # Build the .app bundle
make rebuild    # Clean and rebuild
make run        # Launch the app
make install    # Install to /Applications
make clean      # Remove build artifacts
make info       # Show app information
```

### Adding New Features

The codebase is organized into clear modules:

- **Models** - Add new data models for features
- **Views** - Create new SwiftUI views (organized by feature)
- **Services** - Implement new blocking or monitoring services

### Debug Mode

Run with debug output:
```bash
swift run --configuration debug
```

## Roadmap

### Planned Features
- [ ] Floating focus bar overlay
- [ ] Custom keyboard shortcuts
- [ ] Statistics and analytics dashboard
- [ ] Pomodoro timer integration
- [ ] Website whitelist during sessions
- [ ] iCloud sync for presets
- [ ] iOS companion app
- [ ] Network-level content filtering (more robust blocking)
- [ ] Notification integration
- [ ] Sound alerts and ambient sounds

## Recent Improvements

### Version 0.1.1
- ✅ **Menu bar timer** - Live countdown display with fixed-width formatting
- ✅ **Arc browser support** - Website blocking now works with Arc
- ✅ **Custom app picker** - Searchable interface to select specific apps to block
- ✅ **Fixed preset sheet bug** - No more blank dialogs on first launch
- ✅ **Improved app icon** - Custom gradient focus icon in menu bar and Dock
- ✅ **Fixed browser force-launch bug** - Browsers no longer open automatically
- ✅ **Refined UI** - Cleaner interface with better spacing and alignment
- ✅ **Enhanced button designs** - More consistent and professional look

## Known Limitations

1. **Website Blocking** - Current implementation uses AppleScript which:
   - Only monitors browsers that are already running
   - Checks tabs every 2 seconds (not instant)
   - Limited Firefox support
   - Requires Automation permissions for each browser
   
   *Future improvement: Implement Network Extension for system-level filtering*

2. **App Blocking** - Apps can be force-relaunched by determined users
   
   *Future improvement: Use Screen Time API for stronger blocking*

3. **Permissions** - Requires manual permission grants on first run

4. **Browser Monitoring** - Only works when browsers are actively running

## Documentation

- **[RELEASE.md](RELEASE.md)** - Building & installation guide
- **[CODE_STRUCTURE.md](CODE_STRUCTURE.md)** - Code organization
- **[FEATURES.md](FEATURES.md)** - Feature roadmap
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Add your license here]

## Acknowledgments

Inspired by [Raycast Focus](https://www.raycast.com/core-features/focus) and other productivity tools.

---

**Built with ❤️ using Swift and SwiftUI**
