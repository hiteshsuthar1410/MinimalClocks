//
//  SigninUsingEmailView.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 05/02/25.
//

import SwiftUI

struct SigninUsingEmailView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email",
                      text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                // Validate non-empty fields
                guard !email.isEmpty, !password.isEmpty else {
                    errorMessage = "Email and password cannot be empty."
                    showError = true
                    return
                }
                
                // Validate email format using custom isValidEmail property (assumed to be implemented in an extension)
                guard email.isValidEmail else {
                    errorMessage = "Please enter a valid email."
                    showError = true
                    return
                }
                
                // Validate password requirements, e.g., minimum 6 characters
                guard password.count >= 6 else {
                    errorMessage = "Password must be at least 6 characters long."
                    showError = true
                    return
                }
                
                // If all validations pass, proceed with user creation
                Task {
                    try await AuthenticationManager.shared.createUser(email: email, password: password)
                }
            }) {
                Text("Sign In")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        // Added alert to show error messages upon validation failure
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {
                // Dismiss alert on OK button tap
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            Task {
                if let id = try await AuthenticationManager.shared.getCurrentUserToken() {
                    debugPrint("Login token: \(id)")
                }
            }
        }
    }
}

#Preview {
    SigninUsingEmailView()
}
