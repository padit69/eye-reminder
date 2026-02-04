# Health Reminder for macOS

A comprehensive macOS menu bar application that helps you maintain healthy habits while working. Get gentle reminders to rest your eyes, stay hydrated, and move around - all with a beautiful, modern interface.

## Features

### 🎯 Multiple Reminder Types

**👁️ Eyes Reminder** - Follow the 20-20-20 rule
- Rest your eyes every 20 minutes (customizable: 5-60 minutes)
- Look at something 20 feet away
- Reduces eye strain from extended screen time

**💧 Water Reminder** - Stay hydrated throughout the day
- Reminds you to drink water every 30 minutes (customizable: 5-60 minutes)
- Helps maintain focus and overall health
- Can be enabled/disabled independently

**🏃 Stand Up Reminder** - Keep your body moving
- Prompts you to stand and stretch every 45 minutes (customizable: 5-60 minutes)
- Improves circulation and reduces fatigue
- Can be enabled/disabled independently

### ⚙️ Powerful Customization

✨ **Individual Controls** - Enable/disable each reminder type independently

⏱️ **Flexible Intervals** - Set different intervals for each reminder (5-60 minutes)

⏰ **Adjustable Duration** - Configure how long reminders stay on screen (10-120 seconds)

🎬 **Preview Mode** - Test each reminder type before applying settings

🚀 **Launch at Login** - Automatically start when you log in (optional)

### 🎨 Beautiful User Interface

🌈 **Modern Design** - Glassmorphism effects with smooth gradient backgrounds

💫 **Breathing Animations** - Calming icon animations that help you relax

🎯 **Type-Specific Colors** - Each reminder has its own color scheme (Cyan for eyes, Blue for water, Green for movement)

📊 **Live Countdown** - Real-time countdown display with animated progress rings

🖥️ **Full-Screen Overlay** - Gentle, semi-transparent overlay that won't jar your workflow

### 📱 Menu Bar Integration

📍 **Status Display** - See countdown timers for all active reminders at a glance

⏯️ **Quick Controls** - Start/Pause all reminders with one click

⚡ **Individual Status** - Each reminder shows its own countdown and enable/disable state

🎛️ **Easy Access** - Settings and controls always available from menu bar

### 🎮 User Experience

🎯 **Manual Dismiss** - Press ESC or click the dismiss button to skip a break

🔄 **Auto-Dismiss** - Reminders automatically close after the configured duration

⌨️ **Keyboard Shortcuts** - Quick actions with ESC key

🎨 **Eye-Friendly Colors** - Following Apple's Human Interface Guidelines with soft, calming colors

## How to Use

### Starting the App

1. Launch `Health Reminder.app`
2. The app icon (❤️) will appear in your menu bar
3. Click "Start All" to begin receiving reminders

### Menu Bar Controls

Click the menu bar icon to see:

- **Active Reminders Status** - Real-time countdown for each reminder type
  - 👁️ **Eyes** - Shows time until next eye break (cyan indicator)
  - 💧 **Water** - Shows time until water reminder (blue indicator)  
  - 🏃 **Stand Up** - Shows time until movement reminder (green indicator)
- **Start All / Pause All** - Toggle all reminders on/off with one click
- **Settings** - Open comprehensive settings window
- **Quit** - Exit the application

### Settings Window

The settings window has multiple tabs for complete customization:

#### 📋 Reminders Tab
Configure each reminder type independently:

**Eye Health**
- Enable/disable eye reminders
- Set interval (5-60 minutes, default: 20)
- View helpful tips about the 20-20-20 rule

**Hydration**
- Enable/disable water reminders
- Set interval (5-60 minutes, default: 30)
- Get hydration tips

**Movement**
- Enable/disable stand-up reminders
- Set interval (5-60 minutes, default: 45)
- Learn about circulation benefits

#### ⚙️ General Tab
- **Display Duration**: How long reminders stay visible (10-120 seconds)
- **Test Reminder**: Preview each reminder type before saving
- **Launch at Login**: Auto-start when you log in

#### 🎨 Appearance Tab
- **Sound Effects**: Enable/disable reminder sounds (coming soon)
- **Notifications**: Show system notifications (coming soon)
- **Display Style**: Information about the glassmorphism design

#### 🔧 Advanced Tab
- **Pause on Idle**: Auto-pause when computer is inactive (coming soon)
- **Show Timer in Menu Bar**: Display countdown in menu bar (currently enabled)
- **Reset to Defaults**: Restore all settings to factory defaults

#### ℹ️ About Tab
- App version and information
- Developer details
- Links to GitHub repository
- License information

### Health Guidelines

**The 20-20-20 Rule (Eyes)**
- Every **20 minutes**
- Look at something **20 feet away**
- For at least **20 seconds**
- Reduces eye strain from screen time

**Hydration Reminder (Water)**
- Regular water intake improves focus and energy
- Helps prevent headaches and fatigue
- Maintains overall health

**Movement Reminder (Stand Up)**
- Standing and stretching improves circulation
- Reduces back pain and stiffness
- Boosts energy and productivity

## Building from Source

### Requirements

- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 14.0 or later
- **Swift**: 5.9 or later
- **Development Team**: Required for code signing (can use personal Apple ID)

### Quick Build

1. **Clone the repository**
   ```bash
git clone https://github.com/yourusername/health-reminder.git
cd health-reminder
   ```

2. **Open in Xcode**
   ```bash
   open HealthReminder/HealthReminder.xcodeproj
   ```

3. **Configure signing**
   - Select the project in Xcode
   - Go to "Signing & Capabilities"
   - Select your development team

4. **Build and run**
   - Press `⌘ + R` or click the Run button
   - The app will build and launch

### Build Scripts (Recommended)

We provide convenient scripts for building and packaging:

**Test Build** - Quick build for testing:
```bash
./scripts/test-build.sh
```
This creates a debug build in the default Xcode build directory.

**Create DMG Installer** - Production build with installer:
```bash
./scripts/create-dmg.sh 1.0.0
```
This creates a release build and packages it as a DMG installer.

**Release Script** - Complete release workflow:
```bash
./scripts/release.sh 1.0.0
```
This builds, archives, and prepares a release with all assets.

### Manual Build (Advanced)

**Using xcodebuild:**

```bash
# Debug build
xcodebuild -project HealthReminder/HealthReminder.xcodeproj \
  -scheme HealthReminder \
  -configuration Debug \
  build

# Release build
xcodebuild -project HealthReminder/HealthReminder.xcodeproj \
  -scheme HealthReminder \
  -configuration Release \
  -derivedDataPath ./build \
  build
```

**Archive for distribution:**

```bash
xcodebuild -project HealthReminder/HealthReminder.xcodeproj \
  -scheme HealthReminder \
  -configuration Release \
  -archivePath ./build/HealthReminder.xcarchive \
  archive
```

### Continuous Integration

The project includes GitHub Actions workflows for automated builds:

- **🔨 Build Check** - Validates builds on pull requests (`.github/workflows/build.yml`)
- **✅ PR Check** - Runs tests and linting on PRs (`.github/workflows/pr-check.yml`)
- **🚀 Release** - Automated release builds and DMG creation (`.github/workflows/release.yml`)

**Triggering a release:**
```bash
# Create and push a version tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### Additional Documentation

- 📖 [Quick Start Guide](QUICKSTART.md) - Fast setup instructions
- 📖 [Complete Setup Guide](SETUP_COMPLETE.md) - Detailed build and configuration
- 📖 [Scripts Documentation](scripts/README.md) - Helper scripts reference
- 📖 [Swift Concurrency Fixes](SWIFT_CONCURRENCY_FIXES.md) - Threading and async notes

## Architecture

The app is built with SwiftUI and follows Apple's design patterns for modern macOS applications:

### Core Architecture
- **Menu Bar Integration**: Uses `MenuBarExtra` for native macOS menu bar UI
- **State Management**: `@ObservableObject` and `@MainActor` for thread-safe, reactive state updates
- **Settings Persistence**: Codable structs with UserDefaults for lightweight data storage
- **Full-Screen Overlay**: Custom `NSWindow` subclass with screen-saver level display priority
- **Multi-Timer System**: Independent timers for each reminder type running concurrently
- **Type-Safe Design**: Enum-based reminder types with associated properties

### Design Patterns
- **Singleton Pattern**: Shared `AppState` for global state management
- **Observer Pattern**: SwiftUI's `@Published` and `@ObservedObject` for reactive UI
- **Delegate Pattern**: Timer delegates for coordinated reminder triggering
- **Factory Pattern**: Type-based reminder settings and configurations

## Key Components

### Core Application
- **`HealthReminderApp.swift`** - Main app entry point and scene configuration with SwiftUI lifecycle
- **`AppState.swift`** - Global application state management with published properties for reactive updates

### Timer & Reminder Management
- **`MultiReminderManager.swift`** - Orchestrates multiple independent reminder timers
  - `SingleReminderTimer` - Individual timer for each reminder type
  - Manages enable/disable state for each reminder
  - Coordinates timer starts, stops, and resets
- **`TimerManager.swift`** - Legacy timer management (maintained for backwards compatibility)

### Settings & Configuration
- **`Settings.swift`** - Comprehensive settings system
  - `ReminderType` enum - Defines three reminder types (Eyes, Water, StandUp)
  - `ReminderSettings` - Individual reminder configuration
  - `AppSettings` - Global app settings with Codable support
  - Type-specific defaults and properties (icons, colors, titles)
- **`SettingsView.swift`** - Multi-tab settings interface
  - `RemindersSettingsView` - Configure each reminder type
  - `GeneralSettingsView` - Display duration and preview features
  - `AppearanceSettingsView` - Sound and notification preferences
  - `AdvancedSettingsView` - Advanced options and reset functionality
  - `AboutView` - App information and credits

### User Interface
- **`MenuBarView.swift`** - Menu bar dropdown with status display
  - `TimerStatusRow` - Individual reminder countdown display
  - `SettingsWindowManager` - Manages settings window lifecycle
  - Real-time status updates for all active reminders
- **`ReminderView.swift`** - Full-screen reminder overlay with animations
  - Glassmorphism design with gradient backgrounds
  - Breathing icon animations
  - Animated progress ring with type-specific colors
  - `KeyEventHandlingView` - ESC key handling for dismissal
- **`ReminderOverlayWindow.swift`** - NSWindow configuration for full-screen overlay
  - Screen-saver level window priority
  - Proper window ordering and focus management

## Keyboard Shortcuts

- **ESC** - Dismiss/skip current reminder early
- **⌘ + ,** - Open Settings (from menu bar)
- **⌘ + Q** - Quit application

## Visual Design Features

### Glassmorphism UI
- Semi-transparent backgrounds with blur effects
- Gradient overlays for depth
- Smooth transitions and animations

### Type-Specific Colors
- **Eyes** - Cyan/Turquoise (calming, associated with rest)
- **Water** - Blue (associated with water and hydration)
- **Stand Up** - Green (associated with health and movement)

### Animations
- **Breathing Effect** - Icon pulsing animation for relaxation
- **Progress Ring** - Smooth countdown with angular gradient
- **Entrance/Exit** - Spring animations for gentle appearance
- **Floating Particles** - Subtle background effects

## Permissions

The app requires no special permissions and runs in the macOS App Sandbox for security. No network access, no data collection, no tracking - just local reminders.

## Tips & Best Practices

### Interval Recommendations

**Eye Reminders**
- **Intensive screen work**: 15-20 minutes
- **Moderate use**: 20-30 minutes
- **Light use**: 30-45 minutes

**Water Reminders**
- **Hot environment**: 20-30 minutes
- **Normal conditions**: 30-45 minutes
- **Cool environment**: 45-60 minutes

**Movement Reminders**
- **Sedentary work**: 30-45 minutes
- **Active work**: 45-60 minutes

### Usage Tips

- **Start with defaults**: The default intervals are based on health research
- **Customize gradually**: Adjust intervals based on your comfort and workflow
- **Don't disable all**: Try to keep at least one reminder type active
- **Use preview**: Test reminders before saving to see how they look
- **Combine with breaks**: Use reminders as cues for longer breaks every few hours

### Development & Testing

- **Quick testing**: Set all intervals to 5-10 seconds to test functionality
- **Preview mode**: Use the preview button in settings to test visual appearance
- **ESC dismissal**: Test keyboard shortcuts work properly

### Productivity Integration

- **Pomodoro technique**: Set eye reminder to 25 minutes to align with Pomodoro cycles
- **Meeting schedule**: Adjust intervals around regular meetings
- **Deep work**: Pause reminders during critical focus sessions, resume after
- **Standalone reminders**: Enable only the reminders you need

## Troubleshooting

### Common Issues

**Reminders not appearing**
1. Check if reminders are started (click menu bar icon)
2. Verify reminder types are enabled in Settings > Reminders tab
3. Restart the app

**Timer not counting down**
1. Ensure the app is running (check menu bar)
2. Verify settings show countdown is active
3. Try clicking "Pause All" then "Start All"

**Settings not saving**
1. Click "Save" button in settings window
2. Check for macOS permission issues
3. Restart app to reload settings

**Window stuck on screen**
1. Press ESC key to dismiss
2. Click "Skip Break" button
3. Force quit app if needed (⌘ + Option + ESC)

### System Requirements

If you encounter issues, ensure you have:
- macOS 13.0 (Ventura) or later
- Sufficient memory (app uses minimal resources)
- Display permissions enabled (if prompted)

### Reporting Issues

If problems persist:
1. Note the macOS version you're using
2. Check Console.app for error messages
3. Report issues on GitHub with detailed description
4. Include steps to reproduce the problem

## Support

Need help? Check these resources:
- 📖 [Quick Start Guide](QUICKSTART.md) - Get started quickly
- 🛠️ [Setup Documentation](SETUP_COMPLETE.md) - Detailed setup and build instructions
- 🐛 [GitHub Issues](https://github.com) - Report bugs or request features

## License

This project is open source and available under the MIT License.

## Credits

- **Developer**: Dũng Phùng
- **Design**: Following Apple Human Interface Guidelines
- **Health Guidelines**: Based on recommendations from eye care and health professionals

---

**Take care of your health! ❤️ 👁️ 💧 🏃**
