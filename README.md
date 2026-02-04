# Eye Reminder for macOS

A gentle macOS menu bar application that reminds you to rest your eyes at regular intervals, following the 20-20-20 rule recommended by eye care professionals.

## Features

✨ **Menu Bar App** - Lives in your menu bar, always accessible but never intrusive

⚙️ **Customizable Intervals** - Set reminder intervals from 5 to 60 minutes (default: 20 minutes)

⏱️ **Adjustable Duration** - Configure how long the reminder stays on screen (10-120 seconds, default: 20 seconds)

🎨 **Gentle Full-Screen Overlay** - A calming, semi-transparent overlay that gently reminds you without jarring your workflow

👁️ **Eye-Friendly Design** - Following Apple's Human Interface Guidelines with soft colors and smooth animations

🎯 **Manual Dismiss** - Close the reminder early with ESC key or the dismiss button

🔄 **Auto-Dismiss** - Automatically dismisses after the configured duration

## How to Use

### Starting the App

1. Launch `EyeReminder.app`
2. The app icon (👁️) will appear in your menu bar
3. Click "Start" to begin receiving reminders

### Menu Bar Controls

- **Start/Pause** - Toggle reminders on/off
- **Next reminder in** - Shows countdown to next reminder
- **Settings** - Configure intervals and duration
- **Quit** - Exit the application

### Settings

Access settings by clicking the Settings button in the menu bar:

- **Reminder Interval**: How often you want to be reminded (5-60 minutes)
- **Reminder Duration**: How long the reminder screen stays visible (10-120 seconds)
- **Launch at Login**: Automatically start the app when you log in (optional)

### The 20-20-20 Rule

The default settings follow the 20-20-20 rule recommended by eye doctors:
- Every **20 minutes**
- Look at something **20 feet away**
- For at least **20 seconds**

This helps reduce eye strain from extended screen time.

## Building from Source

### Requirements

- macOS 13.0 or later
- Xcode 14.0 or later
- Swift 5.0 or later

### Build Instructions

1. Clone the repository
2. Open `EyeReminder.xcodeproj` in Xcode
3. Select your development team in the project settings
4. Build and run (⌘R)

**Using Scripts (Recommended):**

```bash
# Test build
./scripts/test-build.sh

# Create DMG installer
./scripts/create-dmg.sh 1.0.0
```

**Using Xcode directly:**

```bash
cd EyeReminder
xcodebuild -project EyeReminder.xcodeproj -scheme EyeReminder -configuration Release build
```

### Creating Releases

For automated releases with GitHub Actions, see:
- 📖 [Release Guide](RELEASE.md) - Quick reference for creating releases
- 📖 [GitHub Actions Setup](GITHUB_ACTIONS_SETUP.md) - Detailed CI/CD documentation
- 🚀 [Release Scripts](scripts/README.md) - Helper scripts for building and releasing

## Architecture

The app is built with SwiftUI and follows Apple's design patterns:

- **Menu Bar Integration**: Uses `MenuBarExtra` for native menu bar UI
- **State Management**: `@ObservableObject` for reactive state updates
- **Settings Persistence**: UserDefaults for lightweight data storage
- **Full-Screen Overlay**: Custom `NSWindow` subclass for screen-saver level display
- **Timer System**: Precise countdown with visual feedback

## Key Components

- `EyeReminderApp.swift` - Main app entry point and scene configuration
- `AppState.swift` - Global application state management
- `Settings.swift` - User preferences and persistence
- `TimerManager.swift` - Timer scheduling and countdown logic
- `MenuBarView.swift` - Menu bar dropdown interface
- `ReminderView.swift` - Full-screen reminder overlay with animations
- `ReminderOverlayWindow.swift` - NSWindow configuration for overlay
- `SettingsView.swift` - Settings configuration interface

## Keyboard Shortcuts

- **ESC** - Dismiss reminder early

## Permissions

The app requires no special permissions and runs in the macOS App Sandbox for security.

## Tips

- **For developers**: Set short intervals (e.g., 10 seconds) during development for quick testing
- **For heavy users**: Consider 15-minute intervals if 20 feels too frequent
- **For light users**: 30-minute intervals work well for less intensive work

## Support

If you encounter any issues:
1. Try restarting the app
2. Check that macOS system permissions allow the app to run
3. Ensure you're running macOS 13.0 or later

## License

This project is open source and available under the MIT License.

---

**Take care of your eyes! 👁️**
