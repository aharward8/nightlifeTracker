//
//  RootView.swift
//  NightTrackers
//
//  Created by Codex on 3/22/26.
//

import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]

    var body: some View {
        NavigationStack {
            Group {
                if let profile = profiles.first {
                    HomeView(profile: profile)
                } else {
                    RegistrationView(store: SwiftDataUserProfileStore(modelContext: modelContext))
                }
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
