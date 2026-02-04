//
//  ReminderOverlayWindow.swift
//  EyeReminder
//
//  Created by Dũng Phùng on 3/2/26.
//

import SwiftUI
import AppKit

class ReminderOverlayWindow: NSWindow {
    init() {
        // Get the main screen frame
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        
        super.init(
            contentRect: screenFrame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Window configuration
        self.level = .screenSaver
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Make window appear on all spaces and above everything
        self.isMovable = false
        self.isMovableByWindowBackground = false
        
        // Ensure window can be released
        self.isReleasedWhenClosed = true
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    deinit {
        print("ReminderOverlayWindow deallocated")
    }
}

class ReminderOverlayWindowController: NSWindowController {
    convenience init(appState: AppState, timerManager: TimerManager) {
        let window = ReminderOverlayWindow()
        self.init(window: window)
        
        let contentView = ReminderView(appState: appState, timerManager: timerManager)
        let hostingView = NSHostingView(rootView: contentView)
        window.contentView = hostingView
    }
    
    deinit {
        print("ReminderOverlayWindowController deallocated")
    }
    
    override func close() {
        // Ensure window is properly closed
        window?.orderOut(nil)
        window?.level = .normal
        super.close()
    }
}
