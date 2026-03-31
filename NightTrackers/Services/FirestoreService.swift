//
//  FirestoreService.swift
//  Services
//
//  Created by Nathan Edwards on 03/25/26
//

import FirebaseFirestore
import FirebaseAuth

final class FirestoreService 
{
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // CREATE USER DOCUMENT
    func createUser(uid: String, email: String, username: String, completion: @escaping (Error?) -> Void) 
    {
        db.collection("users").document(uid).setData([
            "email": email,
            "username": username,
            "createdAt": Timestamp(date: Date())
        ]) { error in
            completion(error)
        }
    }
    
    // ADD FAVORITE
    func addFavorite(name: String, address: String, completion: @escaping (Error?) -> Void) 
    {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(uid)
            .collection("favorites")
            .addDocument(data: [
                "name": name,
                "address": address
            ]) { error in
                completion(error)
            }
    }
    
    // GET FAVORITES
    func fetchFavorites(completion: @escaping ([Favorite]?, Error?) -> Void) 
    {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(uid)
            .collection("favorites")
            .getDocuments { snapshot, error in
                
                if let error = error 
                {
                    completion(nil, error)
                    return
                }
                
                let favorites = snapshot?.documents.map {
                    Favorite(
                        id: $0.documentID,
                        name: $0["name"] as? String ?? "",
                        address: $0["address"] as? String ?? ""
                    )
                }
                
                completion(favorites, nil)
            }
    }
    
    // REMOVE FAVORITE
    func removeFavorite(favoriteId: String, completion: @escaping (Error?) -> Void) 
    {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(uid)
            .collection("favorites")
            .document(favoriteId)
            .delete { error in
                completion(error)
            }
    }
}