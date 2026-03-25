//
//  UserProfileStore.swift
//  NightTrackers
//
//  Created by Codex on 3/22/26.
//

import Foundation
import SwiftData

struct RegistrationDraft: Equatable {
    var firstName: String = ""
    var lastName: String = ""
    var phoneNumber: String = ""
    var photoData: Data? = nil
}

enum RegistrationField: Hashable {
    case firstName
    case lastName
    case phoneNumber
}

struct RegistrationValidationError: LocalizedError, Equatable {
    struct Issue: Equatable {
        let field: RegistrationField
        let message: String
    }

    let issues: [Issue]

    var errorDescription: String? {
        issues.first?.message
    }

    func message(for field: RegistrationField) -> String? {
        issues.first { $0.field == field }?.message
    }
}

struct RegistrationValidator {
    func validate(_ draft: RegistrationDraft) throws -> RegistrationDraft {
        let firstName = draft.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = draft.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneNumber = normalizedPhoneNumber(from: draft.phoneNumber)

        var issues: [RegistrationValidationError.Issue] = []

        if firstName.isEmpty {
            issues.append(.init(field: .firstName, message: "First name is required."))
        }

        if lastName.isEmpty {
            issues.append(.init(field: .lastName, message: "Last name is required."))
        }

        if !(10...15).contains(phoneNumber.count) {
            issues.append(.init(field: .phoneNumber, message: "Enter a valid phone number with at least 10 digits."))
        }

        if !issues.isEmpty {
            throw RegistrationValidationError(issues: issues)
        }

        return RegistrationDraft(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            photoData: draft.photoData
        )
    }

    private func normalizedPhoneNumber(from rawValue: String) -> String {
        let digits = rawValue.unicodeScalars.filter(CharacterSet.decimalDigits.contains)
        return String(String.UnicodeScalarView(digits))
    }
}

@MainActor
protocol UserProfileStore {
    func fetchPrimaryProfile() throws -> UserProfile?
    @discardableResult
    func save(_ draft: RegistrationDraft) throws -> UserProfile
}

@MainActor
struct SwiftDataUserProfileStore: UserProfileStore {
    let modelContext: ModelContext

    private let validator = RegistrationValidator()

    func fetchPrimaryProfile() throws -> UserProfile? {
        var descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\UserProfile.createdAt)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    @discardableResult
    func save(_ draft: RegistrationDraft) throws -> UserProfile {
        let sanitizedDraft = try validator.validate(draft)

        if let existingProfile = try fetchPrimaryProfile() {
            existingProfile.firstName = sanitizedDraft.firstName
            existingProfile.lastName = sanitizedDraft.lastName
            existingProfile.phoneNumber = sanitizedDraft.phoneNumber
            existingProfile.photoData = sanitizedDraft.photoData

            try modelContext.save()
            return existingProfile
        }

        let profile = UserProfile(
            firstName: sanitizedDraft.firstName,
            lastName: sanitizedDraft.lastName,
            phoneNumber: sanitizedDraft.phoneNumber,
            photoData: sanitizedDraft.photoData
        )

        modelContext.insert(profile)
        try modelContext.save()
        return profile
    }
}
