//
//  AuthenticationService.swift
//  Services
//
//  Created by Nathan Edwards on 03/25/26
//

import FirebaseAuth

final class AuthService 
{
    
    static let shared = AuthService()
    private init() {}
    
    // SIGN UP
    func signUp(email: String, password: String, username: String, completion: @escaping (Error?) -> Void) 
    {
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error = error 
            {
                completion(error)
                return
            }
            
            guard let user = result?.user else { return }
            
            FirestoreService.shared.createUser(
                uid: user.uid,
                email: email,
                username: username,
                completion: completion
            )
        }
    }
    
    // LOGIN
    func login(email: String, password: String, completion: @escaping (Error?) -> Void) 
    {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }
    
    // LOGOUT
    func logout() 
    {
        try? Auth.auth().signOut()
    }
    
    // CURRENT USER
    var currentUserId: String? 
    {
        Auth.auth().currentUser?.uid
    }
}