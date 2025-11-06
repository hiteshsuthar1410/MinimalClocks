//
//  UserManager.swift
//  MinimalClocks
//
//  Created by Auto on 05/02/25.
//

import Foundation
import FirebaseAuth

extension Notification.Name {
    static let userDataDidChange = Notification.Name("userDataDidChange")
}

/// Model for storing user data locally
struct AppUser: Codable {
    var id: String
    var email: String?
    var displayName: String?
    var firstName: String?
    var lastName: String?
    var photoURL: String?
}

/// Manager class for saving and loading user data from UserDefaults
final class UserManager {
    static let shared = UserManager()
    
    private let userDefaults: UserDefaults
    private let userKey = "savedAppUser"
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    /// Save user data after login
    func saveUser(from firebaseUser: FirebaseAuth.User) {
        // Extract name components from displayName if available
        let nameComponents = firebaseUser.displayName?.components(separatedBy: " ") ?? []
        let firstName = nameComponents.first
        let lastName = nameComponents.count > 1 ? nameComponents.dropFirst().joined(separator: " ") : nil
        
        let appUser = AppUser(
            id: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName,
            firstName: firstName,
            lastName: lastName,
            photoURL: firebaseUser.photoURL?.absoluteString
        )
        
        saveUser(appUser)
    }
    
    /// Save AppUser object
    func saveUser(_ user: AppUser) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userKey)
            // Post notification for UI updates
            NotificationCenter.default.post(name: .userDataDidChange, object: nil)
        }
    }
    
    /// Load saved user data
    func loadUser() -> AppUser? {
        guard let data = userDefaults.data(forKey: userKey),
              let user = try? JSONDecoder().decode(AppUser.self, from: data) else {
            return nil
        }
        return user
    }
    
    /// Clear user data on logout
    func clearUser() {
        userDefaults.removeObject(forKey: userKey)
        // Post notification for UI updates
        NotificationCenter.default.post(name: .userDataDidChange, object: nil)
    }
    
    /// Get user's display name (prioritizes displayName, then firstName, then "User")
    func getUserDisplayName() -> String {
        guard let user = loadUser() else {
            return "User"
        }
        
        if let displayName = user.displayName, !displayName.isEmpty {
            return displayName
        } else if let firstName = user.firstName, !firstName.isEmpty {
            return firstName
        } else {
            return "User"
        }
    }
    
    /// Get user's email
    func getUserEmail() -> String? {
        return loadUser()?.email
    }
    
    /// Get user's photo URL
    func getUserPhotoURL() -> String? {
        return loadUser()?.photoURL
    }
}

