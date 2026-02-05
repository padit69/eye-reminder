//
//  HealthReminderApp.swift
//  HealthReminder
//
//  Created by Dũng Phùng on 3/2/26.
//

import SwiftUI
import AppKit
import Combine

@main
struct HealthReminderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared
    @StateObject private var timerManager: TimerManager
    @StateObject private var multiReminderManager: MultiReminderManager
    @StateObject private var updateChecker = UpdateChecker()
    
    init() {
        let state = AppState.shared
        _timerManager = StateObject(wrappedValue: TimerManager(appState: state))
        _multiReminderManager = StateObject(wrappedValue: MultiReminderManager(appState: state))
    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(
                appState: appState,
                timerManager: timerManager,
                multiReminderManager: multiReminderManager
            )
            .environmentObject(updateChecker)
            .onAppear {
                appDelegate.appState = appState
                appDelegate.timerManager = timerManager
                appDelegate.multiReminderManager = multiReminderManager
                appDelegate.setupObservers()
                
                // Check for updates on launch
                updateChecker.checkForUpdatesOnLaunch()
            }
        } label: {
            Image(systemName: "eye.fill")
        }
        .menuBarExtraStyle(.window)
    }
}

// AppDelegate to handle reminder overlay
class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindowController: ReminderOverlayWindowController?
    var appState: AppState?
    var timerManager: TimerManager?
    var multiReminderManager: MultiReminderManager?
    private var cancellables = Set<AnyCancellable>()
    private var wasRunningBeforeSleep: Bool = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon for menu bar app
        NSApp.setActivationPolicy(.accessory)
        
        // Setup sleep/wake observers
        setupSleepWakeObservers()
    }
    
    private func setupSleepWakeObservers() {
        // Observe when Mac is going to sleep
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        
        // Observe when Mac wakes up
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }
    
    @objc private func systemWillSleep() {
        Task { @MainActor in
            guard let multiReminderManager = multiReminderManager else { return }
            
            // Remember if timers were running before sleep
            wasRunningBeforeSleep = multiReminderManager.isRunning
            
            // Pause timers if they're running
            if wasRunningBeforeSleep {
                print("Mac going to sleep - pausing timers")
                multiReminderManager.pause()
            }
        }
    }
    
    @objc private func systemDidWake() {
        Task { @MainActor in
            guard let multiReminderManager = multiReminderManager else { return }
            
            // Resume timers if they were running before sleep
            if wasRunningBeforeSleep {
                print("Mac woke up - resuming timers")
                multiReminderManager.start()
                wasRunningBeforeSleep = false
            }
        }
    }
    
    deinit {
        // Remove observers when deallocating
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    @MainActor
    func setupObservers() {
        guard let appState = appState, 
              let multiReminderManager = multiReminderManager else { return }
        
        // Observe reminder state changes
        appState.$showingReminder
            .sink { [weak self] showingReminder in
                Task { @MainActor in
                    // Only show reminder if manager is actually running
                    if showingReminder && multiReminderManager.isRunning {
                        self?.showReminderOverlay(appState: appState, multiReminderManager: multiReminderManager)
                    } else if !showingReminder {
                        self?.hideReminderOverlay()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func showReminderOverlay(appState: AppState, multiReminderManager: MultiReminderManager) {
        // Close existing overlay if any
        hideReminderOverlay()
        
        // Create and show new overlay (using timerManager for backwards compatibility)
        overlayWindowController = ReminderOverlayWindowController(
            appState: appState,
            timerManager: TimerManager(appState: appState)
        )
        overlayWindowController?.showWindow(nil)
        overlayWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @MainActor
    func hideReminderOverlay() {
        guard let window = overlayWindowController?.window else { return }
        
        // Reset window level to normal before closing
        window.level = .normal
        
        // Order out the window (remove from screen)
        window.orderOut(nil)
        
        // Close the window
        overlayWindowController?.close()
        
        // Clear the reference
        overlayWindowController = nil
        
        // Return focus to previous app
        NSApp.deactivate()
    }
}
