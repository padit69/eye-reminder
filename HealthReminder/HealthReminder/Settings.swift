//
//  Settings.swift
//  HealthReminder
//
//  Created by Dũng Phùng on 3/2/26.
//

import Foundation
import SwiftUI

enum ReminderType: String, Codable, CaseIterable, Identifiable {
    case eyes = "Eyes"
    case water = "Water"
    case standup = "Stand Up"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .eyes: return "eye.fill"
        case .water: return "drop.fill"
        case .standup: return "figure.stand"
        }
    }
    
    var color: Color {
        switch self {
        case .eyes: return .cyan
        case .water: return .blue
        case .standup: return .green
        }
    }
    
    var title: String {
        switch self {
        case .eyes: return "Time to Rest Your Eyes"
        case .water: return "Time to Drink Water"
        case .standup: return "Time to Stand Up"
        }
    }
    
    var subtitle: String {
        switch self {
        case .eyes: return "Look at something 20 feet away"
        case .water: return "Stay hydrated for better health"
        case .standup: return "Stretch and move around"
        }
    }
    
    var helper: String {
        switch self {
        case .eyes: return "Give your eyes a break"
        case .water: return "Keep your body hydrated"
        case .standup: return "Improve your circulation"
        }
    }
    
    var defaultInterval: Int {
        switch self {
        case .eyes: return 20
        case .water: return 30
        case .standup: return 45
        }
    }
}

struct ReminderSettings: Codable {
    var enabled: Bool
    var intervalMinutes: Int
    var durationSeconds: Int = 20
    
    init(enabled: Bool = true, intervalMinutes: Int = 20) {
        self.enabled = enabled
        self.intervalMinutes = intervalMinutes
    }
}

struct AppSettings: Codable {
    var eyesReminder: ReminderSettings = ReminderSettings(enabled: true, intervalMinutes: 20)
    var waterReminder: ReminderSettings = ReminderSettings(enabled: true, intervalMinutes: 30)
    var standupReminder: ReminderSettings = ReminderSettings(enabled: true, intervalMinutes: 45)
    var launchAtLogin: Bool = false
    
    private static let userDefaultsKey = "HealthReminderSettings"
    
    // Legacy support
    var reminderIntervalMinutes: Int {
        get { eyesReminder.intervalMinutes }
        set { eyesReminder.intervalMinutes = newValue }
    }
    
    var reminderDurationSeconds: Int {
        get { eyesReminder.durationSeconds }
        set { 
            eyesReminder.durationSeconds = newValue
            waterReminder.durationSeconds = newValue
            standupReminder.durationSeconds = newValue
        }
    }
    
    func settings(for type: ReminderType) -> ReminderSettings {
        switch type {
        case .eyes: return eyesReminder
        case .water: return waterReminder
        case .standup: return standupReminder
        }
    }
    
    mutating func setSettings(_ settings: ReminderSettings, for type: ReminderType) {
        switch type {
        case .eyes: eyesReminder = settings
        case .water: waterReminder = settings
        case .standup: standupReminder = settings
        }
    }
    
    static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: AppSettings.userDefaultsKey)
        }
    }
}
