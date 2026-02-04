//
//  TimerManager.swift
//  EyeReminder
//
//  Created by Dũng Phùng on 3/2/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TimerManager: ObservableObject {
    @Published var timeRemaining: Int = 0
    @Published var isRunning: Bool = false
    
    private var timer: Timer?
    private var nextReminderDate: Date?
    private let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func start() {
        guard !isRunning else { return }
        
        isRunning = true
        scheduleNextReminder()
        startCountdown()
    }
    
    func stop() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        nextReminderDate = nil
        timeRemaining = 0
    }
    
    func reset() {
        stop()
        start()
    }
    
    private func scheduleNextReminder() {
        let intervalSeconds = appState.settings.reminderIntervalMinutes * 60
        nextReminderDate = Date().addingTimeInterval(TimeInterval(intervalSeconds))
        timeRemaining = intervalSeconds
    }
    
    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.triggerReminder()
                }
            }
        }
    }
    
    private func triggerReminder() {
        appState.showingReminder = true
        scheduleNextReminder()
    }
    
    func dismissReminder() {
        appState.showingReminder = false
    }
    
    func formatTimeRemaining() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
