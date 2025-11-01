//
//  LoginView.swift
//  MinimalClocks
//
//  Created by NovoTrax Dev1 on 29/10/25.
//


import SwiftUI
import AuthenticationServices
import GoogleSignInSwift
import FirebaseCore
import GoogleSignIn
import FirebaseAuth

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showSheet = true
    
    func signinWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError(AuthenticationError.clientIDNotFound.localizedDescription)
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else {
            print("There is no root VC")
            return false
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                throw AuthenticationError.tokenMissing
            }
            let accessToken = user.accessToken
            let credentials = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            _ = try await Auth.auth().signIn(with: credentials)
            return true
            
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    var body: some View {
        ZStack {
            // Background with gradient overlay
            ZStack {
                Image("credit_cards_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                // Gradient overlay
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.15, blue: 0.35).opacity(0.8),
                        Color(red: 0.15, green: 0.25, blue: 0.5).opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            // Skip button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        // Handle skip action
                        print("Skip tapped")
                    } label: {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.trailing, 20)
                .padding(.top, 50)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showSheet) {
            // Sheet content
            VStack(spacing: 20) {
                // Handle indicator
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                Spacer()
                
                VStack(spacing: 16) {
                    
                    Text("Welcome 👋")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .padding()
                    
                    // Apple Sign In
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            print("Sign in successful: \(authorization)")
                        case .failure(let error):
                            print("Sign in failed: \(error)")
                        }
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    
                    // Google Sign In button
                    Button {
                        Task {
                            let success = await signinWithGoogle()
                            if success {
                                
                            } else {
                                
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image("img_google")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.red, .blue, .green, .yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Sign in with Google")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(.white))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    }
                    
                    // Divider with "or"
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("or")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // Skip button
                    Button {
                        // Handle Skip
                        print("Skip tapped")
                    } label: {
                        Text("Skip now")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.4, blue: 1.0),
                                        Color(red: 0.3, green: 0.5, blue: 1.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color(red: 0.2, green: 0.4, blue: 1.0).opacity(0.3), radius: 12, y: 6)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .presentationDetents([.height(440)])
            .presentationDragIndicator(.hidden)
            .presentationBackgroundInteraction(.disabled)
            .presentationBackground(.regularMaterial)
            .interactiveDismissDisabled()
        }
    }
}

#Preview {
    LoginView()
}
