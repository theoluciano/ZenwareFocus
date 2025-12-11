# Zenware Focus - Code Structure

## Overview

The codebase has been refactored into a clean, professional structure following best practices for SwiftUI applications. The code is organized by feature and responsibility, making it easy to maintain and extend.

## Directory Structure

```
Sources/ZenwareFocus/
├── ZenwareFocusApp.swift          # App entry point & menu bar setup
├── Models/                         # Data models & business logic
│   ├── FocusSession.swift         # Session data model & enums
│   └── FocusManager.swift         # State management & session logic
├── Services/                       # Business logic services
│   ├── AppBlockerService.swift    # Application blocking logic
│   └── WebsiteBlockerService.swift # Website blocking logic
└── Views/                          # UI components
    ├── FocusView.swift            # Main container view
    ├── ActiveSession/             # Active session UI
    │   ├── ActiveSessionView.swift
    │   └── ControlButton.swift
    ├── AppPicker/                 # App selection UI
    │   ├── AppPickerSheet.swift
    │   ├── AppPickerRow.swift
    │   └── AppIconView.swift
    ├── History/                   # Session history UI
    │   ├── HistoryView.swift
    │   └── HistoryCard.swift
    ├── Presets/                   # Preset management UI
    │   ├── PresetsView.swift
    │   ├── PresetCard.swift
    │   └── GoalInputSheet.swift
    ├── StartSession/              # Session creation UI
    │   ├── StartSessionView.swift
    │   ├── CategoryButton.swift
    │   └── DurationButton.swift
    └── Shared/                    # Reusable components
        ├── FlowLayout.swift       # Custom layout for wrapping
        └── FocusTab.swift         # Tab enum definition
```

## Design Principles

### 1. **Single Responsibility**
Each file has one clear purpose:
- Views handle UI presentation
- Models handle data structure
- Services handle business logic
- Shared components are reusable

### 2. **DRY (Don't Repeat Yourself)**
- Common UI components are extracted (buttons, cards, etc.)
- Shared layouts are in `Shared/`
- Formatting logic is encapsulated in components

### 3. **Feature-Based Organization**
Views are grouped by feature:
- `StartSession/` - Everything for creating sessions
- `ActiveSession/` - Everything for running sessions
- `History/` - Everything for viewing history
- `Presets/` - Everything for managing presets
- `AppPicker/` - Everything for selecting apps

### 4. **Component Hierarchy**
```
FocusView (Container)
├── HeaderView
├── TabBar
└── Content (based on state)
    ├── StartSessionView
    │   ├── DurationButton (x6)
    │   └── CategoryButton (x6)
    ├── ActiveSessionView
    │   └── ControlButton (x3)
    ├── PresetsView
    │   └── PresetCard (x4)
    └── HistoryView
        └── HistoryCard (x10)
```

## File Descriptions

### App Entry Point
- **ZenwareFocusApp.swift**: Main app structure, menu bar setup, popover configuration

### Models
- **FocusSession.swift**: 
  - `FocusSession` struct - Core session data
  - `BlockCategory` enum - Predefined blocking categories
  - `FocusPreset` struct - Saved session templates
  - `SnoozeState` struct - Temporary access tracking

- **FocusManager.swift**:
  - Session lifecycle management (start, pause, resume, stop)
  - Block management (apply/remove)
  - Snooze handling
  - Data persistence (UserDefaults)
  - Preset management
  - History management

### Services
- **AppBlockerService.swift**:
  - Monitor running applications
  - Hide/unhide apps (not quit)
  - Show block notifications
  - Track hidden apps for restoration

- **WebsiteBlockerService.swift**:
  - Browser detection and monitoring
  - AppleScript execution for tab control
  - Safari/Chrome/Firefox support

### Views

#### Main Container
- **FocusView.swift**:
  - Main container view
  - HeaderView - App title and quit button
  - TabBar - Tab navigation UI
  - State-based content switching

#### Start Session
- **StartSessionView.swift**: Main session creation form
- **DurationButton.swift**: Reusable duration selector button
- **CategoryButton.swift**: Reusable category toggle button

#### Active Session
- **ActiveSessionView.swift**: Running session display
- **ControlButton.swift**: Reusable action button (pause/stop/extend)

#### Presets
- **PresetsView.swift**: Preset list view
- **PresetCard.swift**: Individual preset display card
- **GoalInputSheet.swift**: Modal for entering goal before starting

#### History
- **HistoryView.swift**: Session history list
- **HistoryCard.swift**: Individual history item card

#### App Picker
- **AppPickerSheet.swift**: Modal for selecting apps
- **AppPickerRow.swift**: Individual app row with icon
- **AppIconView.swift**: App icon loader and display

#### Shared
- **FlowLayout.swift**: Custom SwiftUI layout for wrapping items
- **FocusTab.swift**: Tab enum with titles and icons

## Benefits of This Structure

### Maintainability
- Easy to find specific functionality
- Clear separation of concerns
- Changes isolated to specific features

### Scalability
- Easy to add new features without affecting existing code
- New views can be added to appropriate folders
- Shared components promote consistency

### Testability
- Components can be tested in isolation
- Clear boundaries between layers
- Services are independent and testable

### Collaboration
- Multiple developers can work on different features
- Clear ownership of files
- Reduced merge conflicts

## Adding New Features

### New View Component
1. Identify which feature it belongs to
2. Create file in appropriate folder
3. Keep it focused and single-purpose

### New Service
1. Create file in `Services/`
2. Keep business logic separate from UI
3. Make it reusable and testable

### New Model
1. Add to `Models/` folder
2. Keep data structures clean
3. Conform to `Codable` for persistence

## Code Style

### Naming Conventions
- **Views**: `ComponentNameView.swift` (e.g., `StartSessionView.swift`)
- **Components**: `ComponentName.swift` (e.g., `DurationButton.swift`)
- **Models**: Descriptive nouns (e.g., `FocusSession.swift`)
- **Services**: `ServiceNameService.swift` (e.g., `AppBlockerService.swift`)

### Organization Within Files
```swift
import Statements

struct ViewName: View {
    // MARK: - Properties
    @State private var property
    
    // MARK: - Body
    var body: some View { }
    
    // MARK: - Subviews
    private var subview: some View { }
    
    // MARK: - Actions
    private func action() { }
}
```

## Future Improvements

Potential areas for further refactoring:
- Extract common styling into a `Theme.swift`
- Create a `Constants.swift` for magic numbers
- Add unit tests for services
- Add SwiftUI previews for all components
- Create a `ViewModels/` layer if complexity grows

---

**Version**: 0.1.1  
**Last Updated**: 2024  
**Status**: ✅ Production Ready
