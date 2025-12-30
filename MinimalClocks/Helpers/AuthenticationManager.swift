//
//  AuthenticationManager.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 05/02/25.
//

import Foundation
struct AuthDataResult {
    let uuid: String
    let email: String?
    let photoURL: String?
}

import Foundation
import FirebaseAuth

final class AuthenticationManager {

    static let shared = AuthenticationManager()
    
    private init() { }
    
    
    enum AuthenticationError: Error {
        case noUserRecord
        case firebaseError(Error)
        case noCurrentUser
    }
    
    func createUser(email: String, password: String) async throws -> AuthDataResult {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = authResult.user
            return AuthDataResult(uuid: user.uid, email: user.email, photoURL: user.photoURL?.absoluteString)
        } catch {
            throw AuthenticationError.firebaseError(error)
        }
    }
    
    func getCurrentUserToken() async throws -> String? {
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthenticationError.noCurrentUser
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            currentUser.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error {
                    continuation.resume(throwing: AuthenticationError.firebaseError(error))
                } else {
                    continuation.resume(returning: idToken)
                }
            }
        }
    }
}
