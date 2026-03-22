//
//  UserProfile.swift
//  NightTrackers
//
//  Created by Codex on 3/22/26.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var firstName: String
    var lastName: String
    var phoneNumber: String
    @Attribute(.externalStorage) var photoData: Data?
    var createdAt: Date

    init(
        firstName: String = "",
        lastName: String = "",
        phoneNumber: String = "",
        photoData: Data? = nil,
        createdAt: Date = .now
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.photoData = photoData
        self.createdAt = createdAt
    }

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
