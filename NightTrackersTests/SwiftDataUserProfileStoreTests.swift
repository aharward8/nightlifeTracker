//
//  SwiftDataUserProfileStoreTests.swift
//  NightTrackersTests
//
//  Created by Codex on 3/22/26.
//

import SwiftData
import Testing
@testable import NightTrackers

@MainActor
struct SwiftDataUserProfileStoreTests {

    @Test func savePersistsAndUpdatesASingleProfile() throws {
        let container = try ModelContainer(
            for: UserProfile.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let store = SwiftDataUserProfileStore(modelContext: context)

        _ = try store.save(
            RegistrationDraft(
                firstName: "Taylor",
                lastName: "North",
                phoneNumber: "5551234567"
            )
        )

        let savedProfile = try store.fetchPrimaryProfile()
        #expect(savedProfile?.fullName == "Taylor North")
        #expect(savedProfile?.phoneNumber == "5551234567")

        _ = try store.save(
            RegistrationDraft(
                firstName: "Taylor",
                lastName: "North",
                phoneNumber: "+1 555 000 1111"
            )
        )

        let profiles = try context.fetch(FetchDescriptor<UserProfile>())
        #expect(profiles.count == 1)
        #expect(profiles.first?.phoneNumber == "15550001111")
    }
}
