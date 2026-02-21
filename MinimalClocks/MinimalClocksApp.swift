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
            ContentView()
        }
        .modelContainer(for: QuoteModel.self)
    }
}

