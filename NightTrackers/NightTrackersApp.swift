//
//  NightTrackersApp.swift
//  NightTrackers

import SwiftData
import SwiftUI

@main
struct NightTrackersApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let sharedModelContainer: ModelContainer = {
        do {
            return try ModelContainer(
                for: UserProfile.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Failed to create the app database: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}