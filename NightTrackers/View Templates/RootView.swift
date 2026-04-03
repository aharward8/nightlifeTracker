//  RootView.swift
//  NightTrackers

import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]

    // One shared LocationManager for the whole app
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        LocationPermissionGate(locationManager: locationManager) {
            NavigationStack {
                Group {
                    if let profile = profiles.first {
                        HomeView(profile: profile, locationManager: locationManager)
                    } else {
                        RegistrationView(store: SwiftDataUserProfileStore(modelContext: modelContext))
                    }
                }
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}