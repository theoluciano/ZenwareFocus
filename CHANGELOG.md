# Changelog

All notable changes to Zenware Focus will be documented in this file.

## [0.1.1] - 2024

### 🐛 Bug Fixes
- **Critical**: Fixed browser force-launch bug that caused Safari and Chrome to repeatedly open
  - Website blocker now only monitors browsers that are already running
  - Added checks to prevent AppleScript from launching browsers
  - Blocking only activates when there's an active focus session
- Fixed missing AppKit import in WebsiteBlockerService

### ✨ UI Improvements
- Complete UI redesign with cleaner, more polished interface
- Improved visual hierarchy throughout the app
- Better spacing and padding consistency
- Enhanced button designs with better visual feedback
- Refined color scheme with subtle gradients
- Fixed broken UI elements and layout issues
- Improved tab bar with selection indicators
- Better typography with system fonts
- Enhanced active session view with circular progress
- Cleaner preset cards with better category badges
- Improved history view with better empty states
- More professional control buttons with icons
- Better goal input sheet design

### 🎨 Design Changes
- Increased window size to 380x520 for better content display
- Added gradient to timer progress circle
- Improved button states (hover, selected, disabled)
- Better icon usage throughout the interface
- Consistent corner radius (8-12px) across components
- Improved color opacity for backgrounds
- Better monospaced font for timer display
- Enhanced empty state designs

### 🔧 Technical Improvements
- Browser monitoring only starts when session is active
- Added running app checks before AppleScript execution
- Improved error handling in AppleScript calls
- Better state management for website blocker
- Reduced unnecessary timer creation
- More efficient browser detection

## [0.1.0] - 2024

### 🎉 Initial Release
- Focus session management (start, pause, resume, stop, extend)
- Application blocking with real-time monitoring
- Website blocking for Safari, Chrome, and Firefox
- 6 predefined block categories (Social Media, Shopping, Entertainment, Gaming, Messaging, News)
- Custom session presets with 4 defaults
- Snooze functionality (3-minute temporary access)
- Session history tracking
- Menu bar integration
- Data persistence with UserDefaults
- Clean SwiftUI interface
- Swift Package Manager build system
- macOS 13.0+ support

### 📦 Project Structure
- Modular architecture with Models, Views, and Services
- Well-documented codebase
- Comprehensive README and guides
- Quick start documentation
- Feature roadmap

### 🔑 Core Features
- Goal-based focus sessions
- Flexible duration selection (5 min to 4 hours)
- Visual countdown timer with progress indicator
- Real-time app launch detection and termination
- AppleScript-based browser tab monitoring
- Session state persistence across restarts
- User-friendly alerts and notifications

---

## Version History

- **v0.1.1** - UI refinements and critical bug fixes
- **v0.1.0** - Initial release with core functionality

## Upcoming Features

See [FEATURES.md](FEATURES.md) for the complete roadmap.

### Next Release (v0.2.0)
- Floating focus bar overlay
- Global keyboard shortcuts
- Custom notifications
- Dark mode improvements
- Statistics dashboard (basic)

### Future Releases
- Network Extension for system-level website blocking
- Screen Time API integration
- iOS companion app
- iCloud sync
- Pomodoro timer
- Team features
- Calendar integration

---

**Note**: This project follows [Semantic Versioning](https://semver.org/).

- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backward compatible manner
- **PATCH** version for backward compatible bug fixes