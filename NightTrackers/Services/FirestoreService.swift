//
//  FirestoreService.swift
//  Services
//
//  Created by Nathan Edwards on 03/25/26
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

struct RemoteUserProfile {
    let email: String
    let firstName: String
    let lastName: String
    let phoneNumber: String
}

final class FirestoreService {
    static let shared = FirestoreService()

    private let db = Firestore.firestore()

    private init() {}

    func favoriteErrorMessage(for error: Error, action: String) -> String {
        let nsError = error as NSError

        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost, NSURLErrorCannotConnectToHost:
                return "No internet connection. Favorite couldn't be \(action) in Firebase."
            default:
                break
            }
        }

        if nsError.domain.contains("FIRFirestoreErrorDomain"),
           let code = FirestoreErrorCode.Code(rawValue: nsError.code) {
            switch code {
            case .permissionDenied:
                return "Firestore permission denied for favorites. Check your rules for users/{uid}/favorites."
            case .unavailable:
                return "Firestore is temporarily unavailable. Try again in a moment."
            default:
                break
            }
        }

        return "Favorite \(action) failed: \(nsError.localizedDescription) [\(nsError.domain):\(nsError.code)]"
    }

    func logFavoriteError(_ error: Error, action: String) {
        let nsError = error as NSError
        print("Favorite \(action) error -> domain: \(nsError.domain), code: \(nsError.code), message: \(nsError.localizedDescription)")
    }

    func createUser(uid: String, email: String, draft: RegistrationDraft) async throws {
        let data: [String: Any] = [
            "email": email,
            "firstName": draft.firstName,
            "lastName": draft.lastName,
            "phoneNumber": draft.phoneNumber,
            "createdAt": Timestamp(date: Date())
        ]

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.collection("users").document(uid).setData(data) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    func fetchUser(uid: String) async throws -> RemoteUserProfile {
        try await withCheckedThrowingContinuation { continuation in
            db.collection("users").document(uid).getDocument { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard
                    let data = snapshot?.data(),
                    let email = data["email"] as? String,
                    let firstName = data["firstName"] as? String,
                    let lastName = data["lastName"] as? String,
                    let phoneNumber = data["phoneNumber"] as? String
                else {
                    continuation.resume(throwing: NSError(
                        domain: "NightTrackers.FirestoreService",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "We couldn't find your profile in the database."]
                    ))
                    return
                }

                continuation.resume(returning: RemoteUserProfile(
                    email: email,
                    firstName: firstName,
                    lastName: lastName,
                    phoneNumber: phoneNumber
                ))
            }
        }
    }

    func addFavorite(locationName: String, lat: Double, long: Double) async throws -> FirestoreFavorite {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "NightTrackers.FirestoreService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "You must be signed in to save favorites."]
            )
        }

        let collection = db.collection("users").document(uid).collection("favorites")
        let data: [String: Any] = [
            "locationName": locationName,
            "lat": lat,
            "long": long
        ]

        let document = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<DocumentReference, Error>) in
            var reference: DocumentReference?
            reference = collection.addDocument(data: data) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let reference {
                    continuation.resume(returning: reference)
                } else {
                    continuation.resume(throwing: NSError(
                        domain: "NightTrackers.FirestoreService",
                        code: 500,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to create favorite document."]
                    ))
                }
            }
        }

        return FirestoreFavorite(id: document.documentID, locationName: locationName, lat: lat, long: long)
    }

    func fetchFavorites() async throws -> [FirestoreFavorite] {
        guard let uid = Auth.auth().currentUser?.uid else {
            return []
        }

        let snapshot = try await db.collection("users")
            .document(uid)
            .collection("favorites")
            .getDocuments()

        return snapshot.documents.map {
            FirestoreFavorite(
                id: $0.documentID,
                locationName: $0["locationName"] as? String ?? "",
                lat: $0["lat"] as? Double ?? 0,
                long: $0["long"] as? Double ?? 0
            )
        }
    }

    func removeFavorite(documentID: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        try await db.collection("users")
            .document(uid)
            .collection("favorites")
            .document(documentID)
            .delete()
    }

    func addFavorite(
        locationName: String,
        lat: Double,
        long: Double,
        completion: @escaping (Error?) -> Void
    ) {
        Task {
            do {
                _ = try await addFavorite(locationName: locationName, lat: lat, long: long)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func fetchFavorites(completion: @escaping ([FirestoreFavorite]?, Error?) -> Void) {
        Task {
            do {
                completion(try await fetchFavorites(), nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    func removeFavorite(favoriteId: String, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                try await removeFavorite(documentID: favoriteId)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func deleteUserData(uid: String) async throws {
        let userDocument = db.collection("users").document(uid)
        let collections = [
            userDocument.collection("favorites"),
            userDocument.collection("searchHistory")
        ]

        for collection in collections {
            let snapshot = try await collection.getDocuments()
            for document in snapshot.documents {
                try await document.reference.delete()
            }
        }

        try await userDocument.delete()
    }

    func deleteUser(uid: String, completion: @escaping (Error?) -> Void) {
        Task {
            do {
                try await deleteUserData(uid: uid)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
