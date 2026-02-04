//
//  AppState.swift
//  EyeReminder
//
//  Created by Dũng Phùng on 3/2/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var isReminderActive: Bool = false
    @Published var settings: AppSettings
    @Published var showingSettings: Bool = false
    @Published var showingReminder: Bool = false
    @Published var currentReminderType: ReminderType = .eyes
    
    static let shared = AppState()
    
    private init() {
        self.settings = AppSettings.load()
    }
    
    func toggleReminder() {
        isReminderActive.toggle()
    }
    
    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        newSettings.save()
    }
    
    func showReminder(type: ReminderType) {
        currentReminderType = type
        showingReminder = true
    }
}
