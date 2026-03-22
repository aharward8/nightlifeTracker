//
//  RegistrationValidatorTests.swift
//  NightTrackersTests
//
//  Created by Codex on 3/22/26.
//

import Testing
@testable import NightTrackers

struct RegistrationValidatorTests {

    @Test func trimsNamesAndNormalizesPhoneNumbers() throws {
        let validator = RegistrationValidator()

        let draft = RegistrationDraft(
            firstName: "  Taylor ",
            lastName: " North  ",
            phoneNumber: "+1 (555) 123-4567"
        )

        let validatedDraft = try validator.validate(draft)

        #expect(validatedDraft.firstName == "Taylor")
        #expect(validatedDraft.lastName == "North")
        #expect(validatedDraft.phoneNumber == "15551234567")
    }

    @Test func rejectsMissingRequiredFields() {
        let validator = RegistrationValidator()

        do {
            _ = try validator.validate(
                RegistrationDraft(
                    firstName: " ",
                    lastName: "",
                    phoneNumber: "555"
                )
            )
            Issue.record("Expected registration validation to fail.")
        } catch let error as RegistrationValidationError {
            #expect(error.message(for: .firstName) == "First name is required.")
            #expect(error.message(for: .lastName) == "Last name is required.")
            #expect(error.message(for: .phoneNumber) == "Enter a valid phone number with at least 10 digits.")
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}
