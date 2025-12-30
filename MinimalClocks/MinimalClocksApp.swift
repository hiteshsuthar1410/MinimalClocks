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
    private let authViewModel = AuthenticationViewModel()
    var body: some Scene {
        WindowGroup {
            ZStack {
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
        .animation(.easeInOut(duration: 0.45), value: authViewModel.isAuthenticated)

            
        }
        .modelContainer(for: QuoteModel.self)
    }
}

