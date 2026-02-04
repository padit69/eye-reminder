# Quick Start Guide - Health Reminder

## 🚀 Getting Started (5 minutes)

### 1. Open the Project in Xcode

```bash
cd /Users/dungne/SourceCode/health-reminder/HealthReminder
open HealthReminder.xcodeproj
```

### 2. Run the App

- Press `⌘R` in Xcode to build and run
- Or: Click the Play button in Xcode's toolbar

### 3. Using the App

Once launched, you'll see an eye icon (👁️) in your menu bar:

1. **Click the eye icon** to open the menu
2. **Click "Start"** to begin reminders
3. **Wait** - The first reminder will appear based on your interval setting (default: 20 minutes)

### 4. For Quick Testing

To test the reminder immediately:

1. Click the eye icon in menu bar
2. Click "Settings"
3. Change "Reminder Interval" to **5 minutes**
4. Change "Reminder Duration" to **10 seconds**
5. Click "Save"
6. Click "Start" in the menu bar
7. Wait 5 minutes - the reminder will appear!

### 5. What You'll See

When the reminder triggers:
- 🖥️ Full-screen gentle overlay appears
- 👁️ Eye icon and message: "Time to rest your eyes"
- ⏱️ Countdown timer showing remaining seconds
- ✨ Smooth fade-in/out animations
- 🔘 "Skip (ESC)" button to dismiss early

### 6. Keyboard Shortcuts

- **ESC** - Close reminder early

## 🎯 Recommended Settings

### Default (20-20-20 Rule)
- **Interval**: 20 minutes
- **Duration**: 20 seconds
- Best for: Standard office work

### Intensive Work
- **Interval**: 15 minutes
- **Duration**: 30 seconds
- Best for: Heavy screen time

### Light Use
- **Interval**: 30 minutes
- **Duration**: 20 seconds
- Best for: Occasional computer use

## 🔧 Troubleshooting

### App doesn't appear in menu bar
- Make sure the app is running (check Activity Monitor)
- The eye icon should appear on the right side of the menu bar

### Reminder doesn't show
- Check that you clicked "Start" in the menu
- Verify the countdown is running (shows in menu)

### Can't dismiss reminder
- Press ESC key
- Click the "Skip" button
- Wait for auto-dismiss

## 📝 Development Testing

For quick testing during development:

```bash
# Build and run from terminal
cd /Users/dungne/SourceCode/health-reminder/HealthReminder
xcodebuild -project HealthReminder.xcodeproj -scheme HealthReminder -configuration Debug build
open /Users/dungne/Library/Developer/Xcode/DerivedData/HealthReminder-*/Build/Products/Debug/HealthReminder.app
```

Set interval to 10 seconds and duration to 5 seconds for rapid testing.

## ✅ Features Checklist

- [x] Menu bar app with eye icon
- [x] Start/Pause functionality
- [x] Countdown timer display
- [x] Full-screen gentle overlay
- [x] Configurable intervals (5-60 minutes)
- [x] Configurable duration (10-120 seconds)
- [x] Settings window with sliders
- [x] Manual dismiss (ESC key + button)
- [x] Auto-dismiss after duration
- [x] Smooth animations
- [x] Apple HIG compliant design
- [x] UserDefaults persistence

## 🎨 UI/UX Highlights

- **Gentle colors**: Semi-transparent black overlay with white content card
- **SF Symbols**: Native macOS eye icon
- **Smooth animations**: 0.3s fade-in, 0.2s fade-out
- **Circular countdown**: Visual progress indicator
- **Apple design**: SF Pro font, system colors, standard spacing
- **Menu bar integration**: Native macOS menu bar app

---

**Ready to protect your eyes! 👁️✨**
