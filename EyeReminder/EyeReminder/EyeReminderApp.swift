//
//  EyeReminderApp.swift
//  EyeReminder
//
//  Created by Dũng Phùng on 3/2/26.
//

import SwiftUI
import AppKit
import Combine

@main
struct EyeReminderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared
    @StateObject private var timerManager: TimerManager
    @StateObject private var multiReminderManager: MultiReminderManager
    
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
            .onAppear {
                appDelegate.appState = appState
                appDelegate.timerManager = timerManager
                appDelegate.multiReminderManager = multiReminderManager
                appDelegate.setupObservers()
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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon for menu bar app
        NSApp.setActivationPolicy(.accessory)
    }
    
    func setupObservers() {
        guard let appState = appState, 
              let timerManager = timerManager,
              let multiReminderManager = multiReminderManager else { return }
        
        // Observe reminder state changes
        appState.$showingReminder
            .sink { [weak self] showingReminder in
                if showingReminder {
                    self?.showReminderOverlay(appState: appState, multiReminderManager: multiReminderManager)
                } else {
                    self?.hideReminderOverlay()
                }
            }
            .store(in: &cancellables)
    }
    
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
