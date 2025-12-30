//
//  LoginView.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 29/10/25.
//


import SwiftUI
import AuthenticationServices
import GoogleSignInSwift
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import MeshingKit

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    var loginVM = LoginViewModel()
    @State private var showSheet = true
    @State private var showAnimation = true
    @State private var isWaving = false

    
    var appDisplayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ??
        "Minimal Clocks"
    }
    
    
    var body: some View {
        ZStack {
            MeshingKit.animatedGradient(
                .size3(.arcticAurora),
                        showAnimation: $showAnimation,
                        animationSpeed: 1)
            
            Text(appDisplayName)
                .font(.system(size: 42, weight: .semibold, design: .rounded))
                .padding()
                .offset(y: -160)
                .foregroundStyle(.white)
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
                    
                    HStack {
                        Text("Welcome")
                        Text("👋")
                            .rotationEffect(.degrees(isWaving ? 8 : -8), anchor: .center)
                            .animation(
                                .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true),
                                value: isWaving
                            )
                            .onAppear {
                                isWaving = true
                            }
                    }
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
                        loginVM.loginInProgress = true
                        Task {
                            let success = await loginVM.signinWithGoogle()
                            loginVM.loginInProgress = false
                            if success {
                                Haptic.success()

                            } else {
                                Haptic.error()

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
                            
                            Text(loginVM.loginInProgress ? "Signing in..." : "Sign in with Google")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(.black)
                            
                            if loginVM.loginInProgress {
                                ProgressView().tint(.accentColor)
                            }
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
            .backgroundStyle(.thinMaterial)
            .presentationDetents([.height(440)])
            .presentationDragIndicator(.hidden)
            .presentationBackgroundInteraction(.enabled)
            .presentationBackground(.clear)
            .interactiveDismissDisabled()
        }
    }
}

#Preview {
    LoginView()
}
