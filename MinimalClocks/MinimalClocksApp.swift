//
//  MinimalClocksApp.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 11/01/25.
//

import Firebase
import SwiftData
import SwiftUI

@main
struct MinimalClocksApp: App {
    @StateObject var authViewModel = AuthenticationViewModel()
    var body: some Scene {
        WindowGroup {Group {
            if authViewModel.isLoading {
                // Show a loading screen/spinner while Firebase checks the state
                VStack {
                    ProgressView()
                    Text("Checking session...")
                }
            } else if authViewModel.isAuthenticated {
                // User is signed in (restored from last session)
                ContentView()
            } else {
                // User is signed out (or session expired)
                LoginView()
            }
        }
            
        }
        .modelContainer(for: QuoteModel.self)
    }
    
    init() {
        FirebaseApp.configure()
    }
}

