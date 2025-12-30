//
//  ProfileView.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 02/11/25.
//

import FirebaseAuth
import Kingfisher
import MessageUI
import StoreKit
import SwiftUI

struct ProfileView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.requestReview) var requestReview
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) private var openUrl
    
    @State private var userName: String?
    @State private var userEmail: String?
    @State private var userPhotoURL: String?
    @State private var showFeedbackSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground) // Adapts to light/dark mode
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        HStack {
                            
                            Spacer()
                            
                            Button(role: .none, action: {
                                dismiss()
                            }, label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                
                            })
                            .padding(.top, 8)
                            .offset(x: 8)
                            
                        }
                        
                        List {
                            Section {
                                HStack() {
                                    ZStack {
                                        Group {
                                            if let photoURLString = userPhotoURL, let photoURL = URL(string: photoURLString) {
                                                KFImage(photoURL)
                                                    .placeholder {
                                                        Image(systemName: "person.fill")
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 60, height: 60)
                                                    }
                                                    .resizing(referenceSize: CGSize(width: 180, height: 180), mode: .aspectFill)
                                                    .cacheMemoryOnly()
                                                    .fade(duration: 0.25)
                                                    .onFailure { error in
                                                        print("Failed to load user profile image: \(error)")
                                                    }
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 60, height: 60)
                                                    .clipShape(Circle())
                                            } else {
                                                Image(systemName: "person.fill")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 60, height: 60)
                                                    .clipShape(Circle())
                                            }
                                        }
                                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                                    }
                                    .padding(.bottom, 8)
                                    
                                    VStack(alignment: .leading) {
                                        // User Name
                                        Text(userName ?? "")
                                            .font(Font.appTertiaryTitle)
                                            .foregroundColor(colorScheme == .light ? .black : .white)
                                        
                                        // User Email
                                        if let email = userEmail {
                                            Text(email)
                                                .font(Font.appBody)
                                                .foregroundColor(colorScheme == .light ? .black : .white)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(.thinMaterial.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .listRowInsets(EdgeInsets())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Section(header: Text("Feedback")) {
                                Button("Rate the app", systemImage: "star.fill") {
                                    requestReview()
                                }
                                
                                Button("Submit Feedback", systemImage: "envelope.badge.person.crop") {
                                    if MFMailComposeViewController.canSendMail() {
                                        showFeedbackSheet.toggle()
                                    } else {
                                        sendEmail(openUrl: openUrl)
                                    }
                                }
                            }
                            
                            Section(header: Text("Privacy")) {
                                Label("Delete account", systemImage: "person.slash.fill")
                                
                            }
                            
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        
                        // Logout Button
                        Button {
                            do {
                                try Auth.auth().signOut()
                                // User data will be cleared automatically by AuthenticationViewModel
                                loadUserData() // Refresh UI
                            } catch {
                                print("Error Signing out: \(error)")
                            }
                        } label: {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(colorScheme == .light ? Color(#colorLiteral(red: 0.9019607843, green: 0.1254901961, blue: 0.1254901961, alpha: 1)) : (Color(#colorLiteral(red: 0.698, green: 0.133, blue: 0.133, alpha: 1))))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke((colorScheme == .light ? Color.white.opacity(0.3) : Color.black.opacity(0.3)), lineWidth: 1))
                        }
                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(.horizontal)
                }
            }
            .ignoresSafeArea(edges: [.bottom])
            .sheet(isPresented: $showFeedbackSheet) {
                MailComposerViewController(recipients: ["hiteshsuthar1410@icloud.com"], subject: "App Feedback", messageBody: "")
            }
            .onReceive(NotificationCenter.default.publisher(for: .userDataDidChange)) { _ in
                // Reload user data when it changes
                loadUserData()
            }
            .task {
                loadUserData()
            }
        }
    }
    
    private func loadUserData() {
        userName = UserManager.shared.getUserDisplayName()
        userEmail = UserManager.shared.getUserEmail()
        userPhotoURL = UserManager.shared.getUserPhotoURL()
    }
    
    private func sendEmail(openUrl: OpenURLAction) {
        let urlString = "mailto:hiteshsuthar1410@icloud.com?subject=Feedback&body=Hi%20there!"
        guard let url = URL(string: urlString) else { return }
        
        openUrl(url) { accepted in
            if !accepted {
                // Handle the error, e.g., show an alert
            }
        }
    }
}

#Preview {
    ProfileView()
}
