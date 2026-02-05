//
//  UpdateChecker.swift
//  HealthReminder
//
//  Created by Dũng Phùng on 5/2/26.
//

import Foundation
import SwiftUI
import Combine

struct AppVersion: Codable {
    let version: String
    let releaseDate: String
    let downloadURL: String
    let releaseNotes: String
    let minimumOSVersion: String
}

@MainActor
class UpdateChecker: ObservableObject {
    @Published var isCheckingForUpdates = false
    @Published var updateAvailable = false
    @Published var latestVersion: AppVersion?
    @Published var showUpdateAlert = false
    @Published var errorMessage: String?
    
    // Update endpoint URL - you can change this to your own server or GitHub releases
    private let updateURL = "https://raw.githubusercontent.com/yourusername/health-reminder/main/version.json"
    
    // Current app version from Info.plist
    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    // Check for updates on app launch
    func checkForUpdatesOnLaunch() {
        // Check if we should auto-check (e.g., once per day)
        let lastCheckKey = "LastUpdateCheckDate"
        let lastCheck = UserDefaults.standard.object(forKey: lastCheckKey) as? Date ?? Date.distantPast
        let daysSinceLastCheck = Calendar.current.dateComponents([.day], from: lastCheck, to: Date()).day ?? 0
        
        // Only check once per day
        guard daysSinceLastCheck >= 1 else { return }
        
        Task {
            await checkForUpdates(silent: true)
            UserDefaults.standard.set(Date(), forKey: lastCheckKey)
        }
    }
    
    // Manual check for updates
    func checkForUpdates(silent: Bool = false) async {
        isCheckingForUpdates = true
        errorMessage = nil
        
        do {
            guard let url = URL(string: updateURL) else {
                throw UpdateError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw UpdateError.networkError
            }
            
            let version = try JSONDecoder().decode(AppVersion.self, from: data)
            latestVersion = version
            
            // Compare versions
            if isNewerVersion(version.version, than: currentVersion) {
                updateAvailable = true
                if !silent {
                    showUpdateAlert = true
                }
            } else if !silent {
                // Show "You're up to date" message
                errorMessage = "You're using the latest version!"
            }
            
        } catch {
            if !silent {
                errorMessage = "Failed to check for updates: \(error.localizedDescription)"
            }
            print("Update check failed: \(error)")
        }
        
        isCheckingForUpdates = false
    }
    
    // Compare version strings (e.g., "1.0.0" vs "1.0.1")
    private func isNewerVersion(_ newVersion: String, than currentVersion: String) -> Bool {
        let newComponents = newVersion.split(separator: ".").compactMap { Int($0) }
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }
        
        for i in 0..<max(newComponents.count, currentComponents.count) {
            let new = i < newComponents.count ? newComponents[i] : 0
            let current = i < currentComponents.count ? currentComponents[i] : 0
            
            if new > current {
                return true
            } else if new < current {
                return false
            }
        }
        
        return false
    }
    
    // Open download URL in browser
    func downloadUpdate() {
        guard let version = latestVersion,
              let url = URL(string: version.downloadURL) else { return }
        NSWorkspace.shared.open(url)
    }
}

enum UpdateError: LocalizedError {
    case invalidURL
    case networkError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid update URL"
        case .networkError:
            return "Network error occurred"
        case .decodingError:
            return "Failed to decode update information"
        }
    }
}
