//
//  AuthenticationError.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 30/10/25.
//


import Foundation

public enum AuthenticationError: Error {
    // Common auth-related failures
    case clientIDNotFound
    case invalidCredentials               // wrong username / password
    case tokenExpired                     // access token expired
    case tokenMissing                     // access token expired
    case unauthorized                     // 401 - no rights
    case forbidden                        // 403 - not allowed
    case accountLocked(reason: String?)   // account locked on server
    case userNotFound                     // user doesn't exist
    case mfaRequired                      // multi-factor required
    case invalidOTP                       // one-time pass invalid
    case passwordTooWeak                  // client-side validation
    case networkError(underlying: Error?) // network / transport problems
    case serverError(code: Int, message: String?)
    case cancelled                        // user cancelled
    case unknown                          // fallback for unexpected errors
}

extension AuthenticationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password."
        case .tokenExpired:
            return "Your session expired. Please sign in again."
        case .tokenMissing:
            return "Token not found. Please sign in again."
        case .unauthorized:
            return "You are not authorized to perform this action."
        case .forbidden:
            return "Access to this resource is forbidden."
        case .accountLocked(let reason):
            return reason ?? "Your account has been locked. Contact support."
        case .userNotFound:
            return "No account found for the provided credentials."
        case .mfaRequired:
            return "Additional verification is required."
        case .invalidOTP:
            return "Invalid verification code."
        case .passwordTooWeak:
            return "Password does not meet security requirements."
        case .networkError:
            return "Network connection error. Please check your internet."
        case .serverError(_, let message):
            return message ?? "Server error occurred. Try again later."
        case .cancelled:
            return "Operation cancelled."
        case .unknown:
            return "An unknown error occurred."
        case .clientIDNotFound:
            return "Google Client ID not found in InfoPlist."
        }
    }

    public var failureReason: String? {
        switch self {
        case .invalidCredentials: return "Credentials rejected by server."
        case .tokenExpired: return "Access token no longer valid."
        case .accountLocked: return "Account locked by server policy."
        case .networkError(let underlying): return underlying?.localizedDescription
        case .serverError(let code, _): return "Server returned code \(code)."
        default: return nil
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidCredentials:
            return "Please check your username and password and try again."
        case .tokenExpired:
            return "Sign in again to renew your session."
        case .networkError:
            return "Check your internet connection or try again later."
        case .mfaRequired:
            return "Complete two-factor authentication to continue."
        default:
            return nil
        }
    }
}
