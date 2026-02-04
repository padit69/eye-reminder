//
//  MultiReminderManager.swift
//  HealthReminder
//
//  Created by Dũng Phùng on 3/2/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SingleReminderTimer: ObservableObject {
    let type: ReminderType
    @Published var timeRemaining: Int = 0
    @Published var isEnabled: Bool = true
    
    private var timer: Timer?
    private let appState: AppState
    
    init(type: ReminderType, appState: AppState) {
        self.type = type
        self.appState = appState
        self.isEnabled = appState.settings.settings(for: type).enabled
    }
    
    func start() {
        guard isEnabled else { return }
        
        let settings = appState.settings.settings(for: type)
        timeRemaining = settings.intervalMinutes * 60
        
        timer?.invalidate()
        
        // Schedule timer on main run loop to avoid threading issues
        timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.trigger()
                }
            }
        }
        
        // Add to main run loop with common mode
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        timeRemaining = 0
    }
    
    func reset() {
        stop()
        start()
    }
    
    private func trigger() {
        appState.showReminder(type: type)
        // Restart timer for next reminder
        start()
    }
    
    func formatTimeRemaining() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

@MainActor
class MultiReminderManager: ObservableObject {
    @Published var eyesTimer: SingleReminderTimer
    @Published var waterTimer: SingleReminderTimer
    @Published var standupTimer: SingleReminderTimer
    @Published var isRunning: Bool = false
    
    private let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        self.eyesTimer = SingleReminderTimer(type: .eyes, appState: appState)
        self.waterTimer = SingleReminderTimer(type: .water, appState: appState)
        self.standupTimer = SingleReminderTimer(type: .standup, appState: appState)
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        
        eyesTimer.start()
        waterTimer.start()
        standupTimer.start()
    }
    
    func stop() {
        isRunning = false
        
        eyesTimer.stop()
        waterTimer.stop()
        standupTimer.stop()
    }
    
    func reset() {
        stop()
        start()
    }
    
    func timer(for type: ReminderType) -> SingleReminderTimer {
        switch type {
        case .eyes: return eyesTimer
        case .water: return waterTimer
        case .standup: return standupTimer
        }
    }
    
    func dismissReminder() {
        appState.showingReminder = false
    }
}
