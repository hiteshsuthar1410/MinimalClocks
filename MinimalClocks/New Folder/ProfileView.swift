//
//  ProfileView.swift
//  MinimalClocks
//
//  Created by NovoTrax Dev1 on 02/11/25.
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
                Color.clear
                    .backgroundStyle(.background)
                    .ignoresSafeArea()
                
                // 👇 Radial gradient layer
                GeometryReader { geo in
                    RadialGradient(
                        colors: [
//                            (colorScheme == .light ? Color(#colorLiteral(red: 0.7725490196, green: 0.7294117647, blue: 1, alpha: 1)) : Color(#colorLiteral(red: 0.031, green: 0.125, blue: 0.243, alpha: 1))),
                            (colorScheme == .light ? Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) : Color(#colorLiteral(red: 0.141, green: 0.216, blue: 0.282, alpha: 1))),
                            (colorScheme == .light ? Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) : Color(#colorLiteral(red: 0.333, green: 0.486, blue: 0.576, alpha: 1))),
                            (colorScheme == .light ? Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) : Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                        ],
                        center: .top,
                        startRadius: 0,
                        endRadius: geo.size.height * 0.3) // controls how far fade extends
                    .ignoresSafeArea(edges: .top)
                }
                
                // 👇 Your screen content
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
                            .padding(.vertical)
                            
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
                                .background(.thinMaterial.opacity(colorScheme == .light ? 0.8 : 0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .listRowBackground(Color.clear)
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
                            .frame(height: 10)
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
