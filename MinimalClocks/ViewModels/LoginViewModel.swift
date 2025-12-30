//
//  LoginViewModel.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 29/12/25.
//

import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

@MainActor @Observable
final class LoginViewModel {
    
    var loginInProgress: Bool = false
    
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
            let authDataResult = try await Auth.auth().signIn(with: credentials)
            _ = authDataResult.user
            return true
            
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
