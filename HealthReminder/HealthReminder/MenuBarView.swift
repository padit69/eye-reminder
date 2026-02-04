//
//  MenuBarView.swift
//  HealthReminder
//
//  Created by Dũng Phùng on 3/2/26.
//

import SwiftUI
import AppKit

struct MenuBarView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var multiReminderManager: MultiReminderManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "heart.text.square.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("Health Reminder")
                        .font(.headline)
                }
                
                if multiReminderManager.isRunning {
                    Text("Active reminders")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("All reminders paused")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            
            Divider()
            
            // Timers Status
            if multiReminderManager.isRunning {
                VStack(spacing: 0) {
                    TimerStatusRow(
                        type: .eyes,
                        timer: multiReminderManager.eyesTimer
                    )
                    
                    Divider()
                    
                    TimerStatusRow(
                        type: .water,
                        timer: multiReminderManager.waterTimer
                    )
                    
                    Divider()
                    
                    TimerStatusRow(
                        type: .standup,
                        timer: multiReminderManager.standupTimer
                    )
                }
            }
            
            Divider()
            
            // Controls
            VStack(spacing: 0) {
                Button(action: {
                    if multiReminderManager.isRunning {
                        multiReminderManager.stop()
                    } else {
                        multiReminderManager.start()
                    }
                }) {
                    HStack {
                        Image(systemName: multiReminderManager.isRunning ? "pause.fill" : "play.fill")
                        Text(multiReminderManager.isRunning ? "Pause All" : "Start All")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.clear)
                .onHover { isHovered in
                    if isHovered {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                
                Button(action: {
                    openSettingsWindow()
                }) {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .onHover { isHovered in
                    if isHovered {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                
                Divider()
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Quit")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .onHover { isHovered in
                    if isHovered {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
        }
        .frame(width: 280)
    }
    
    private func openSettingsWindow() {
        // Close the menu bar popover first
        closeMenuBarPopover()
        
        // Small delay to ensure popover closes before opening settings
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Try to find existing Settings window first
            if let existingWindow = NSApp.windows.first(where: { $0.title == "Settings" }) {
                NSApp.activate(ignoringOtherApps: true)
                existingWindow.makeKeyAndOrderFront(nil)
            } else {
                // Create new settings window
                let settingsView = SettingsView(appState: appState, timerManager: timerManager)
                let hostingController = NSHostingController(rootView: settingsView)
                
                let window = NSWindow(contentViewController: hostingController)
                window.title = "Settings"
                window.styleMask = [.titled, .closable]
                window.setContentSize(NSSize(width: 700, height: 500))
                window.center()
                window.isReleasedWhenClosed = false
                window.titlebarAppearsTransparent = false
                window.backgroundColor = NSColor.windowBackgroundColor
                
                NSApp.activate(ignoringOtherApps: true)
                window.makeKeyAndOrderFront(nil)
                
                // Store reference to keep window alive
                SettingsWindowManager.shared.settingsWindow = window
            }
        }
    }
    
    private func closeMenuBarPopover() {
        // Find and close the menu bar popover window
        for window in NSApp.windows {
            if window.level == .popUpMenu {
                window.close()
                break
            }
        }
    }
}

// Timer Status Row Component
struct TimerStatusRow: View {
    let type: ReminderType
    @ObservedObject var timer: SingleReminderTimer
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: type.icon)
                .font(.system(size: 14))
                .foregroundColor(timer.isEnabled ? type.color : .gray)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(type.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(timer.isEnabled ? .primary : .secondary)
                
                if timer.isEnabled {
                    Text(timer.formatTimeRemaining())
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                } else {
                    Text("Disabled")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if timer.isEnabled {
                Circle()
                    .fill(type.color)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .animation(.none, value: timer.timeRemaining) // Disable animation for performance
    }
}

// Singleton to keep reference to settings window
class SettingsWindowManager {
    static let shared = SettingsWindowManager()
    var settingsWindow: NSWindow?
    
    private init() {}
}
