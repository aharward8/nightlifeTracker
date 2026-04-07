//
//  AuthenticationService.swift
//  Services
//
//  Created by Nathan Edwards on 03/25/26
//

import FirebaseAuth

final class AuthService {
    static let shared = AuthService()

    private init() {}

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    func signUp(email: String, password: String, draft: RegistrationDraft) async throws {
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, Error>) in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: NSError(
                        domain: "NightTrackers.AuthService",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "Firebase didn't return a user account."]
                    ))
                }
            }
        }

        do {
            try await FirestoreService.shared.createUser(uid: result.user.uid, email: email, draft: draft)
        } catch {
            try? await delete(user: result.user)
            throw error
        }
    }

    func login(email: String, password: String) async throws -> RemoteUserProfile {
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, Error>) in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: NSError(
                        domain: "NightTrackers.AuthService",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "Firebase didn't return a signed-in user."]
                    ))
                }
            }
        }

        return try await FirestoreService.shared.fetchUser(uid: result.user.uid)
    }

    func logout() throws {
        guard Auth.auth().currentUser != nil else {
            return
        }

        try Auth.auth().signOut()
    }

    func deleteCurrentUser() async throws {
        guard let user = Auth.auth().currentUser else {
            return
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            FirestoreService.shared.deleteUser(uid: user.uid) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }

        try await delete(user: user)
    }

    private func delete(user: User) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            user.delete { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
