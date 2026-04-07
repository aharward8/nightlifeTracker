//  RootView.swift
//  NightTrackers

import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var favoritesManager: FavoritesManager
    @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]

    @StateObject private var locationManager = LocationManager()
    @State private var navigationPath = NavigationPath()
    @State private var forceRegistration = false

    var body: some View {
        LocationPermissionGate(locationManager: locationManager) {
            Group {
                if forceRegistration || profiles.first == nil {
                    RegistrationView(store: SwiftDataUserProfileStore(modelContext: modelContext))
                } else {
                    NavigationStack(path: $navigationPath) {
                        if let profile = profiles.first {
                            HomeView(
                                profile: profile,
                                locationManager: locationManager,
                                onLogout: logout,
                                onDeleteProfile: deleteProfile
                            )
                        }
                    }
                }
            }
            .onChange(of: profiles.count) { _, newCount in
                if newCount > 0 {
                    forceRegistration = false
                }
            }
        }
    }

    private func logout() async throws {
        try AuthService.shared.logout()
        try clearLocalSession()
    }

    private func deleteProfile() async throws {
        let currentUserID = AuthService.shared.currentUserId
        try clearLocalSession()

        guard currentUserID != nil else {
            return
        }

        Task {
            do {
                try await AuthService.shared.deleteCurrentUser()
            } catch {
                print("Delete account remote cleanup failed: \(error.localizedDescription)")
            }
        }
    }

    private func clearLocalSession() throws {
        forceRegistration = true
        navigationPath = NavigationPath()
        favoritesManager.items.removeAll()
        try SwiftDataUserProfileStore(modelContext: modelContext).deletePrimaryProfile()
    }
}

#Preview {
    RootView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
