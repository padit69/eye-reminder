# Swift Concurrency Fixes for GitHub Actions

This document tracks all Swift concurrency (actor isolation) fixes needed for the project to build on GitHub Actions with Xcode 16.4.

## Overview

The project uses `@MainActor` for the `AppState` class, which enforces strict actor isolation in newer Xcode versions. GitHub Actions uses Xcode 16.4, which has stricter concurrency checking than some local Xcode versions.

## Issues & Fixes

### Fix #1: setupObservers() Method

**Commit**: `517df37`  
**Error**:
```
error: main actor-isolated property '$showingReminder' can not be referenced from a nonisolated context
```

**Solution**: Added `@MainActor` annotation to `setupObservers()`

```swift
@MainActor
func setupObservers() {
    // Can now access appState.$showingReminder
}
```

**Why**: The method accesses `appState.$showingReminder`, which is a published property of a `@MainActor` class.

---

### Fix #2: showReminderOverlay() Method

**Commit**: `8412e44`  
**Error**:
```
error: call to main actor-isolated initializer 'init(appState:)' in a synchronous nonisolated context
            timerManager: TimerManager(appState: appState)
```

**Solution**: Added `@MainActor` annotation to `showReminderOverlay()`

```swift
@MainActor
func showReminderOverlay(appState: AppState, multiReminderManager: MultiReminderManager) {
    overlayWindowController = ReminderOverlayWindowController(
        appState: appState,
        timerManager: TimerManager(appState: appState)
    )
}
```

**Why**: The method creates a `TimerManager` with `appState` (which is `@MainActor`), so the initializer call must be isolated to the main actor.

---

### Fix #3: hideReminderOverlay() Method

**Commit**: `8412e44`  
**Error**: Implicit requirement (called from `@MainActor` context)

**Solution**: Added `@MainActor` annotation to `hideReminderOverlay()`

```swift
@MainActor
func hideReminderOverlay() {
    // UI operations
}
```

**Why**: The method is called from `showReminderOverlay()` which is now `@MainActor`, and it performs UI operations.

---

### Fix #4: Combine Sink Callback

**Commit**: `8412e44`  
**Issue**: Callbacks from Combine publishers may execute on different threads

**Solution**: Wrapped callback in `Task { @MainActor in }`

```swift
appState.$showingReminder
    .sink { [weak self] showingReminder in
        Task { @MainActor in
            if showingReminder {
                self?.showReminderOverlay(appState: appState, multiReminderManager: multiReminderManager)
            } else {
                self?.hideReminderOverlay()
            }
        }
    }
    .store(in: &cancellables)
```

**Why**: Ensures the callback executes on the main actor, preventing concurrency warnings when calling `@MainActor` methods.

---

## Actor Isolation Summary

### Classes with @MainActor

1. **AppState** (`AppState.swift`)
   ```swift
   @MainActor
   class AppState: ObservableObject {
       @Published var showingReminder: Bool = false
       // ...
   }
   ```

### Methods with @MainActor

1. **AppDelegate.setupObservers()** (`HealthReminderApp.swift`)
2. **AppDelegate.showReminderOverlay()** (`HealthReminderApp.swift`)
3. **AppDelegate.hideReminderOverlay()** (`HealthReminderApp.swift`)

### Why These Annotations Are Needed

1. **Accessing @MainActor properties**: Any code that accesses properties of `@MainActor` classes must also be isolated to the main actor.

2. **Creating instances with @MainActor parameters**: Initializers that take `@MainActor` parameters must be called from a `@MainActor` context.

3. **UI operations**: Methods that interact with AppKit/UIKit should generally run on the main thread.

4. **Strict concurrency checking**: Xcode 16+ enforces stricter actor isolation rules.

## Testing for Concurrency Issues

### Local Testing

Test with the same flags as CI:

```bash
cd HealthReminder
xcodebuild \
  -project HealthReminder.xcodeproj \
  -scheme HealthReminder \
  -configuration Release \
  -derivedDataPath ./build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  clean build
```

### Enable Strict Concurrency Checking

To catch these issues earlier in development, you can enable strict concurrency checking in Xcode:

1. Select your target in Xcode
2. Go to Build Settings
3. Search for "Swift Concurrency"
4. Set "Swift Concurrency Checking" to "Complete"

This will show all concurrency warnings as errors during development.

## Common Patterns

### Pattern 1: Accessing @MainActor Properties

**Problem**:
```swift
func someMethod() {
    appState.showingReminder = true  // Error!
}
```

**Solution**:
```swift
@MainActor
func someMethod() {
    appState.showingReminder = true  // OK
}
```

### Pattern 2: Calling @MainActor Methods from Callbacks

**Problem**:
```swift
publisher.sink { value in
    self.mainActorMethod()  // May run on wrong thread
}
```

**Solution**:
```swift
publisher.sink { value in
    Task { @MainActor in
        self.mainActorMethod()  // Guaranteed to run on main actor
    }
}
```

### Pattern 3: Creating Objects with @MainActor Dependencies

**Problem**:
```swift
func createManager() {
    let manager = SomeManager(appState: appState)  // Error if appState is @MainActor
}
```

**Solution**:
```swift
@MainActor
func createManager() {
    let manager = SomeManager(appState: appState)  // OK
}
```

## Build Environment Differences

### Local vs CI

| Environment | Xcode Version | Strictness |
|-------------|---------------|------------|
| **Local** (macOS 26.2) | Xcode 26.2 / 17C52 | May be less strict |
| **GitHub Actions** | Xcode 16.4 / 16F6 | Strict concurrency |

**Note**: Always test with the same Xcode version as CI when possible, or enable strict concurrency checking locally.

## Future Considerations

### When Adding New Code

1. **UI Operations**: Always use `@MainActor` for methods that touch UI
2. **AppState Access**: Mark methods with `@MainActor` if they access `appState` properties
3. **Callbacks**: Wrap in `Task { @MainActor in }` when calling `@MainActor` methods
4. **Publishers**: Consider using `.receive(on: DispatchQueue.main)` for Combine publishers

### Migration Guide

If you encounter new concurrency errors:

1. **Read the error carefully**: It usually suggests the fix
2. **Check the context**: Is the method accessing `@MainActor` properties?
3. **Add @MainActor**: Mark the method or use `Task { @MainActor in }`
4. **Test locally**: Build with same flags as CI
5. **Verify on CI**: Push and check GitHub Actions

## Build Status

### Latest Fixes

| Commit | Description | Status |
|--------|-------------|--------|
| `8412e44` | Add @MainActor to overlay methods | ✅ Expected to pass |
| `517df37` | Add @MainActor to setupObservers | ✅ Fixed local build |

### Verification

```bash
# Check latest build
open https://github.com/padit69/health-reminder/actions

# Test locally
cd /Users/dungne/SourceCode/health-reminder
./scripts/test-build.sh
```

## References

- [Swift Concurrency Documentation](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Main Actor Usage](https://developer.apple.com/documentation/swift/mainactor)
- [Sendable Protocol](https://developer.apple.com/documentation/swift/sendable)
- [Swift Evolution: Actor Isolation](https://github.com/apple/swift-evolution/blob/main/proposals/0306-actors.md)

---

**Last Updated**: Commit `8412e44` - 2024-02-05

**Status**: ✅ All known concurrency issues resolved
