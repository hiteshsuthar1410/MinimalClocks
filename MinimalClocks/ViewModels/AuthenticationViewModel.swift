//
//  AuthenticationViewModel.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 30/10/25.
//


import Foundation
import FirebaseAuth
import FirebaseCore // Import FirebaseCore to ensure setup is available

@Observable
final class AuthenticationViewModel {
    
    var user: FirebaseAuth.User?
    var isAuthenticated: Bool = false
    var errorMessage: String?
    var isLoading: Bool = true // A state to indicate the initial check is running
    
    @ObservationIgnored
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        // 1. Initialize Firebase Auth State Listener (Restores authentication state on launch)
        FirebaseApp.configure()
        setupAuthStateListener()
    }
    
    deinit {
        // Clean up the listener when the view model is destroyed
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - State Listener
    
    /**
     Sets up a listener to monitor the user's sign-in status.
     This is called on app launch to restore the previous session.
     */
    private func setupAuthStateListener() {
        // This listener is called immediately after being registered and whenever the user signs in or out.
        self.isLoading = true
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user // Set the user object (nil if signed out)
                self?.isAuthenticated = user != nil // Update the state
                self?.isLoading = false
                self?.errorMessage = nil // Clear any previous error
                
                // Save or clear user data based on auth state
                if let user = user {
                    print("User is signed in with UID: \(user.uid)")
                    // Save user data when logged in
                    UserManager.shared.saveUser(from: user)
                } else {
                    print("User is signed out.")
                    // Clear user data when signed out
                    UserManager.shared.clearUser()
                }
            }
        }
    }

    // MARK: - Authentication Operations

    /**
     Signs in an existing user with email and password.
     */
    func signIn(email: String, password: String) async {
        DispatchQueue.main.async { self.errorMessage = nil }
        
        do {
            // Use Auth.auth().signIn and convert the completion handler to async/await
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            // The authStateDidChangeListener will update the 'user' and 'isAuthenticated' properties.
            print("Successfully signed in user: \(result.user.uid)")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    /**
     Creates a new user with email and password and signs them in.
     */
    func signUp(email: String, password: String) async {
        DispatchQueue.main.async { self.errorMessage = nil }
        
        do {
            // Use Auth.auth().createUser and convert the completion handler to async/await
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            // The authStateDidChangeListener will update the 'user' and 'isAuthenticated' properties.
            print("Successfully signed up new user: \(result.user.uid)")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    /**
     Signs out the current user. This is not an asynchronous call.
     */
    func signOut() {
        DispatchQueue.main.async { self.errorMessage = nil }
        
        do {
            try Auth.auth().signOut()
            // Clear user data on sign out
            UserManager.shared.clearUser()
            // The authStateDidChangeListener will handle updating the state properties.
            print("User signed out successfully.")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    /**
     Deletes the current user's account.
     */
    func deleteAccount() async {
        DispatchQueue.main.async { self.errorMessage = nil }
        
        guard let currentUser = Auth.auth().currentUser else {
            DispatchQueue.main.async { self.errorMessage = "No user is currently signed in." }
            return
        }
        
        do {
            // Use currentUser.delete() and convert the completion handler to async/await
            try await currentUser.delete()
            // The authStateDidChangeListener will handle updating the state properties.
            print("User account deleted successfully.")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
