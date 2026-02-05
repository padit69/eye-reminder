//
//  SettingsView.swift
//  HealthReminder
//
//  Created by Dũng Phùng on 3/2/26.
//

import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case reminders = "Reminders"
    case general = "General"
    case appearance = "Appearance"
    case advanced = "Advanced"
    case about = "About"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .reminders: return "bell.badge.fill"
        case .general: return "gearshape.fill"
        case .appearance: return "paintbrush.fill"
        case .advanced: return "slider.horizontal.3"
        case .about: return "info.circle.fill"
        }
    }
}

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var timerManager: TimerManager
    @State private var selectedTab: SettingsTab = .reminders
    @State private var durationSeconds: Double
    @State private var launchAtLogin: Bool
    @State private var soundEnabled: Bool = true
    @State private var showNotification: Bool = true
    @Environment(\.dismiss) var dismiss
    
    init(appState: AppState, timerManager: TimerManager) {
        self.appState = appState
        self.timerManager = timerManager
        _durationSeconds = State(initialValue: Double(appState.settings.reminderDurationSeconds))
        _launchAtLogin = State(initialValue: appState.settings.launchAtLogin)
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(SettingsTab.allCases, selection: $selectedTab) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 220)
        } detail: {
            // Content area
            VStack(alignment: .leading, spacing: 20) {
                switch selectedTab {
                case .reminders:
                    RemindersSettingsView(appState: appState)
                case .general:
                    GeneralSettingsView(
                        durationSeconds: $durationSeconds,
                        launchAtLogin: $launchAtLogin,
                        appState: appState,
                        timerManager: timerManager
                    )
                case .appearance:
                    AppearanceSettingsView(
                        soundEnabled: $soundEnabled,
                        showNotification: $showNotification,
                        appState: appState,
                        timerManager: timerManager,
                        durationSeconds: durationSeconds
                    )
                case .advanced:
                    AdvancedSettingsView()
                case .about:
                    AboutView()
                }
            }
                
                Divider()
                
                // Footer buttons
                HStack(spacing: 12) {
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button("Save") {
                        saveAllSettings()
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                }
                .padding(20)
                .background(Color(NSColor.windowBackgroundColor))
        
        }
    }
    
    private func saveAllSettings() {
        var newSettings = appState.settings
        newSettings.reminderDurationSeconds = Int(durationSeconds)
        newSettings.launchAtLogin = launchAtLogin
        
        appState.updateSettings(newSettings)
        
        // Reset timer if it's running to apply new interval
        if timerManager.isRunning {
            timerManager.reset()
        }
        
        // Handle launch at login
        setLaunchAtLogin(enabled: launchAtLogin)
        
        dismiss()
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        // This would require implementing SMAppService or LaunchServices
        // For now, we'll just save the preference
        // Implementation can be added later if needed
    }
}

// MARK: - General Settings View
struct GeneralSettingsView: View {
    @Binding var durationSeconds: Double
    @Binding var launchAtLogin: Bool
    @ObservedObject var appState: AppState
    @ObservedObject var timerManager: TimerManager
    
    @State private var eyesDuration: Double
    @State private var waterDuration: Double
    @State private var standupDuration: Double
    @State private var forceFocusMode: Bool
    
    init(durationSeconds: Binding<Double>, launchAtLogin: Binding<Bool>, appState: AppState, timerManager: TimerManager) {
        self._durationSeconds = durationSeconds
        self._launchAtLogin = launchAtLogin
        self.appState = appState
        self.timerManager = timerManager
        self._eyesDuration = State(initialValue: Double(appState.settings.eyesReminder.durationSeconds))
        self._waterDuration = State(initialValue: Double(appState.settings.waterReminder.durationSeconds))
        self._standupDuration = State(initialValue: Double(appState.settings.standupReminder.durationSeconds))
        self._forceFocusMode = State(initialValue: appState.settings.forceFocusMode)
    }
    
    var body: some View {
        Form {
            // Individual Display Duration Section
            Section {
                // Eyes Duration
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Eyes Reminder", systemImage: "eye.fill")
                            .font(.system(size: 13))
                            .symbolRenderingMode(.multicolor)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("\(Int(eyesDuration))")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.cyan)
                                .monospacedDigit()
                            Text("sec")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Slider(value: $eyesDuration, in: 10...120, step: 5)
                        .tint(.cyan)
                        .controlSize(.small)
                        .onChange(of: eyesDuration) { _ in
                            saveSettings()
                        }
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Water Duration
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Water Reminder", systemImage: "drop.fill")
                            .font(.system(size: 13))
                            .symbolRenderingMode(.multicolor)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("\(Int(waterDuration))")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.blue)
                                .monospacedDigit()
                            Text("sec")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Slider(value: $waterDuration, in: 10...120, step: 5)
                        .tint(.blue)
                        .controlSize(.small)
                        .onChange(of: waterDuration) { _ in
                            saveSettings()
                        }
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Stand Up Duration
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Stand Up Reminder", systemImage: "figure.stand")
                            .font(.system(size: 13))
                            .symbolRenderingMode(.multicolor)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("\(Int(standupDuration))")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.green)
                                .monospacedDigit()
                            Text("sec")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Slider(value: $standupDuration, in: 10...120, step: 5)
                        .tint(.green)
                        .controlSize(.small)
                        .onChange(of: standupDuration) { _ in
                            saveSettings()
                        }
                }
                .padding(.vertical, 4)
                
            } header: {
                Text("Display Duration")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            } footer: {
                Text("How long each reminder type will be displayed before auto-closing.")
                    .font(.system(size: 11))
            }
            
            // Focus Mode Section
            Section {
                LabeledContent {
                    Toggle("", isOn: $forceFocusMode)
                        .labelsHidden()
                        .onChange(of: forceFocusMode) { _ in
                            saveSettings()
                        }
                } label: {
                    Label("Force Focus Mode", systemImage: "lock.fill")
                        .font(.system(size: 13))
                }
            } header: {
                Text("Focus Mode")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            } footer: {
                Text("When enabled, you must wait for the entire countdown before closing reminders. Skip button will be disabled.")
                    .font(.system(size: 11))
            }
            
            // Startup Section
            Section {
                LabeledContent {
                    Toggle("", isOn: $launchAtLogin)
                        .labelsHidden()
                } label: {
                    Label("Launch at Login", systemImage: "power.circle")
                        .font(.system(size: 13))
                }
            } footer: {
                Text("Automatically start Health Reminder when you log in to your Mac.")
                    .font(.system(size: 11))
            }
        }
        .formStyle(.grouped)
    }
    
    private func saveSettings() {
        var newSettings = appState.settings
        newSettings.eyesReminder.durationSeconds = Int(eyesDuration)
        newSettings.waterReminder.durationSeconds = Int(waterDuration)
        newSettings.standupReminder.durationSeconds = Int(standupDuration)
        newSettings.forceFocusMode = forceFocusMode
        appState.updateSettings(newSettings)
    }
}

// MARK: - Appearance Settings View
struct AppearanceSettingsView: View {
    @Binding var soundEnabled: Bool
    @Binding var showNotification: Bool
    @ObservedObject var appState: AppState
    @ObservedObject var timerManager: TimerManager
    let durationSeconds: Double
    @State private var selectedStyle: DisplayStyle
    
    init(soundEnabled: Binding<Bool>, showNotification: Binding<Bool>, appState: AppState, timerManager: TimerManager, durationSeconds: Double) {
        self._soundEnabled = soundEnabled
        self._showNotification = showNotification
        self.appState = appState
        self.timerManager = timerManager
        self.durationSeconds = durationSeconds
        self._selectedStyle = State(initialValue: appState.settings.displayStyle)
    }
    
    var body: some View {
        Form {
            // Display Style Section
            Section {
                VStack(spacing: 16) {
                    ForEach(DisplayStyle.allCases) { style in
                        StyleOptionCard(
                            style: style,
                            isSelected: selectedStyle == style,
                            onSelect: {
                                selectedStyle = style
                                var newSettings = appState.settings
                                newSettings.displayStyle = style
                                appState.updateSettings(newSettings)
                            }
                        )
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Reminder Display Style")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            } footer: {
                Text("Choose how reminder screens will appear. Use the preview button below to test each style.")
                    .font(.system(size: 11))
            }
            
            // Preview Section
            Section {
                LabeledContent {
                    Menu {
                        Button(action: { showPreview(type: .eyes) }) {
                            Label("Eyes Reminder", systemImage: "eye.fill")
                        }
                        Button(action: { showPreview(type: .water) }) {
                            Label("Water Reminder", systemImage: "drop.fill")
                        }
                        Button(action: { showPreview(type: .standup) }) {
                            Label("Stand Up Reminder", systemImage: "figure.stand")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Preview")
                                .font(.system(size: 12))
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.system(size: 12))
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.small)
                } label: {
                    Label("Test Display Style", systemImage: "play.circle")
                        .font(.system(size: 13))
                }
            } header: {
                Text("Preview")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            } footer: {
                Text("Preview how reminders will appear with your selected display style.")
                    .font(.system(size: 11))
            }
            
            // Alerts Section
            Section {
                LabeledContent {
                    Toggle("", isOn: $soundEnabled)
                        .labelsHidden()
                } label: {
                    Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                        .font(.system(size: 13))
                }
                
                LabeledContent {
                    Toggle("", isOn: $showNotification)
                        .labelsHidden()
                } label: {
                    Label("Notifications", systemImage: "bell.badge.fill")
                        .font(.system(size: 13))
                }
            } header: {
                Text("Alerts")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            } footer: {
                Text("Play sound and show notifications when reminders appear.")
                    .font(.system(size: 11))
            }
        }
        .formStyle(.grouped)
    }
    
    private func showPreview(type: ReminderType) {
        // Temporarily update settings for preview
        let currentSettings = appState.settings
        var previewSettings = currentSettings
        previewSettings.reminderDurationSeconds = Int(durationSeconds)
        
        // Update settings temporarily
        appState.settings = previewSettings
        
        // Trigger the specific reminder type
        appState.showReminder(type: type)
        
        // Restore original settings after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            appState.settings = currentSettings
        }
    }
}

// MARK: - Style Option Card
struct StyleOptionCard: View {
    let style: DisplayStyle
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Style icon with background
                ZStack {
                    Circle()
                        .fill(isSelected ? style.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: style.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? style.accentColor : .gray)
                }
                
                // Style info
                VStack(alignment: .leading, spacing: 4) {
                    Text(style.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(style.description)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(style.accentColor)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? style.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - DisplayStyle Extension for UI
extension DisplayStyle {
    var accentColor: Color {
        switch self {
        case .modern: return .blue
        case .minimal: return .gray
        case .bold: return .orange
        }
    }
}

// MARK: - Advanced Settings View
struct AdvancedSettingsView: View {
    var body: some View {
        Form {
            Section {
                LabeledContent {
                    Toggle("", isOn: .constant(false))
                        .labelsHidden()
                        .disabled(true)
                } label: {
                    Label("Pause on Idle", systemImage: "moon.fill")
                        .font(.system(size: 13))
                        .symbolRenderingMode(.multicolor)
                }
                
                LabeledContent {
                    Toggle("", isOn: .constant(true))
                        .labelsHidden()
                        .disabled(true)
                } label: {
                    Label("Show Timer in Menu Bar", systemImage: "timer")
                        .font(.system(size: 13))
                }
            } header: {
                Text("Options")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            } footer: {
                Label("Additional features coming soon.", systemImage: "hourglass")
                    .font(.system(size: 11))
            }
            
            Section {
                GroupBox {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.orange.gradient)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Reset All Settings")
                                    .font(.system(size: 13, weight: .medium))
                                
                                Text("This will restore all preferences to their default values.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Button("Reset to Defaults") {
                                // Reset action
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .controlSize(.small)
                        }
                    }
                    .padding(8)
                }
            } header: {
                Text("Reset")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - About View
struct AboutView: View {
    @EnvironmentObject var updateChecker: UpdateChecker
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.pink, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Health Reminder")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text("Version 1.0.0")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                    .padding(.vertical, 12)
                    Spacer()
                }
            }
            
            Section {
                GroupBox {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.blue.gradient)
                        
                        Text("Health Reminder helps you maintain healthy habits while working at your computer. Get timely reminders to rest your eyes, stay hydrated, and keep moving throughout the day.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(8)
                }
            } header: {
                Text("About")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            }
            
            Section {
                LabeledContent("Developer") {
                    Text("Dũng Phùng")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                LabeledContent("Copyright") {
                    Text("© 2026")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                LabeledContent("License") {
                    Text("MIT License")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button(action: {
                    Task {
                        await updateChecker.checkForUpdates(silent: false)
                    }
                }) {
                    LabeledContent {
                        HStack(spacing: 6) {
                            if updateChecker.isCheckingForUpdates {
                                ProgressView()
                                    .controlSize(.small)
                                    .scaleEffect(0.7)
                            } else if updateChecker.updateAvailable {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.green.gradient)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                    } label: {
                        Label("Check for Updates", systemImage: "arrow.down.circle")
                            .font(.system(size: 13))
                    }
                }
                .buttonStyle(.plain)
                .disabled(updateChecker.isCheckingForUpdates)
            } header: {
                Text("Updates")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            } footer: {
                if let error = updateChecker.errorMessage {
                    Text(error)
                        .font(.system(size: 11))
                        .foregroundColor(updateChecker.updateAvailable ? .secondary : .green)
                }
            }
            
            Section {
                Link(destination: URL(string: "https://github.com")!) {
                    LabeledContent {
                        Image(systemName: "arrow.up.forward.square")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } label: {
                        Label("View on GitHub", systemImage: "link")
                            .font(.system(size: 13))
                    }
                }
                
                Link(destination: URL(string: "https://github.com")!) {
                    LabeledContent {
                        Image(systemName: "arrow.up.forward.square")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } label: {
                        Label("Report an Issue", systemImage: "exclamationmark.bubble")
                            .font(.system(size: 13))
                    }
                }
            } header: {
                Text("Resources")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            }
        }
        .formStyle(.grouped)
        .alert("Update Available", isPresented: $updateChecker.showUpdateAlert) {
            Button("Download") {
                updateChecker.downloadUpdate()
            }
            Button("Later", role: .cancel) {}
        } message: {
            if let version = updateChecker.latestVersion {
                Text("Version \(version.version) is now available.\n\n\(version.releaseNotes)")
            }
        }
    }
}

// MARK: - Helper Views
struct SettingRow<Content: View>: View {
    let title: String
    let description: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            content
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.system(size: 13))
        }
    }
}

// MARK: - Reminders Settings View
struct RemindersSettingsView: View {
    @ObservedObject var appState: AppState
    @State private var eyesEnabled: Bool
    @State private var eyesInterval: Double
    @State private var waterEnabled: Bool
    @State private var waterInterval: Double
    @State private var standupEnabled: Bool
    @State private var standupInterval: Double
    
    init(appState: AppState) {
        self.appState = appState
        _eyesEnabled = State(initialValue: appState.settings.eyesReminder.enabled)
        _eyesInterval = State(initialValue: Double(appState.settings.eyesReminder.intervalMinutes))
        _waterEnabled = State(initialValue: appState.settings.waterReminder.enabled)
        _waterInterval = State(initialValue: Double(appState.settings.waterReminder.intervalMinutes))
        _standupEnabled = State(initialValue: appState.settings.standupReminder.enabled)
        _standupInterval = State(initialValue: Double(appState.settings.standupReminder.intervalMinutes))
    }
    
    func saveRemindersSettings() {
        var newSettings = appState.settings
        newSettings.eyesReminder.enabled = eyesEnabled
        newSettings.eyesReminder.intervalMinutes = Int(eyesInterval)
        newSettings.waterReminder.enabled = waterEnabled
        newSettings.waterReminder.intervalMinutes = Int(waterInterval)
        newSettings.standupReminder.enabled = standupEnabled
        newSettings.standupReminder.intervalMinutes = Int(standupInterval)
        appState.updateSettings(newSettings)
    }
    
    var body: some View {
        Form {
            // Eyes Reminder Section
            Section {
                LabeledContent {
                    Toggle("", isOn: $eyesEnabled)
                        .labelsHidden()
                } label: {
                    Label("Rest Your Eyes", systemImage: "eye.fill")
                        .font(.system(size: 13))
                        .symbolRenderingMode(.multicolor)
                }
                
                if eyesEnabled {
                    LabeledContent {
                        HStack(spacing: 8) {
                            Text("\(Int(eyesInterval))")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.cyan)
                                .monospacedDigit()
                            Text("min")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    } label: {
                        Text("Interval")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $eyesInterval, in: 5...60, step: 5) {
                        Text("Interval")
                    } minimumValueLabel: {
                        Text("5")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Text("60")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .controlSize(.small)
                    .tint(.cyan)
                    
                }
            } header: {
                Text("Eye Health")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            } footer: {
                if eyesEnabled {
                    Label("Look at something 20 feet away for 20 seconds to reduce eye strain.", systemImage: "lightbulb.fill")
                        .font(.system(size: 11))
                        .symbolRenderingMode(.multicolor)
                }
            }
            
            // Water Reminder Section
            Section {
                LabeledContent {
                    Toggle("", isOn: $waterEnabled)
                        .labelsHidden()
                } label: {
                    Label("Drink Water", systemImage: "drop.fill")
                        .font(.system(size: 13))
                        .symbolRenderingMode(.multicolor)
                }
                
                if waterEnabled {
                    LabeledContent {
                        HStack(spacing: 8) {
                            Text("\(Int(waterInterval))")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.blue)
                                .monospacedDigit()
                            Text("min")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    } label: {
                        Text("Interval")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $waterInterval, in: 5...60, step: 5) {
                        Text("Interval")
                    } minimumValueLabel: {
                        Text("5")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Text("60")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .controlSize(.small)
                    .tint(.blue)
                    
                }
            } header: {
                Text("Hydration")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            } footer: {
                if waterEnabled {
                    Label("Stay hydrated throughout the day for better health and focus.", systemImage: "lightbulb.fill")
                        .font(.system(size: 11))
                        .symbolRenderingMode(.multicolor)
                }
            }
            
            // Stand Up Reminder Section
            Section {
                LabeledContent {
                    Toggle("", isOn: $standupEnabled)
                        .labelsHidden()
                } label: {
                    Label("Stand Up & Move", systemImage: "figure.stand")
                        .font(.system(size: 13))
                        .symbolRenderingMode(.multicolor)
                }
                
                if standupEnabled {
                    LabeledContent {
                        HStack(spacing: 8) {
                            Text("\(Int(standupInterval))")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.green)
                                .monospacedDigit()
                            Text("min")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    } label: {
                        Text("Interval")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $standupInterval, in: 5...60, step: 5) {
                        Text("Interval")
                    } minimumValueLabel: {
                        Text("5")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Text("60")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .controlSize(.small)
                    .tint(.green)
                
                }
            } header: {
                Text("Movement")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
            } footer: {
                if standupEnabled {
                    Label("Regular movement helps improve circulation and reduces fatigue.", systemImage: "lightbulb.fill")
                        .font(.system(size: 11))
                        .symbolRenderingMode(.multicolor)
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    SettingsView(appState: AppState.shared, timerManager: TimerManager(appState: AppState.shared))
}
