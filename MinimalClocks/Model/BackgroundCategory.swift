//
//  BackgroundCategory.swift
//  MinimalClocks
//
//  Created on 01/01/25.
//

import Foundation

enum BackgroundCategory: String, Codable, CaseIterable {
    case nature = "Nature"
    case abstract = "Abstract"
    case minimal = "Minimal"
    case landscape = "Landscape"
    case city = "City"
    case ocean = "Ocean"
    case forest = "Forest"
    case mountains = "Mountains"
    case sunset = "Sunset"
    case random = "Random"
    
    var displayName: String {
        return rawValue
    }
    
    var unsplashQuery: String? {
        // For random, return nil to fetch truly random images
        if self == .random {
            return nil
        }
        return rawValue.lowercased()
    }
    
    var sampleImageURL: String {
        // Sample Unsplash image URLs for each category (landscape orientation)
        // Using unique, verified Unsplash photo IDs - each with distinct photo ID
        switch self {
        case .nature:
            // Nature - forest path with sunlight (photo-1441974231531)
            return "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=300&fit=crop&q=80"
        case .abstract:
            // Abstract - colorful fluid art (photo-1557672172)
            return "https://images.unsplash.com/photo-1557672172-298e090bd0f1?w=400&h=300&fit=crop&q=80"
        case .minimal:
            // Minimal - simple geometric shapes (photo-1557683316)
            return "https://images.unsplash.com/photo-1557683316-973673baf926?w=400&h=300&fit=crop&q=80"
        case .landscape:
            // Landscape - wide scenic view (photo-1501594907352)
            return "https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=400&h=300&fit=crop&q=80"
        case .city:
            // City - urban skyline (photo-1477959858617)
            return "https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=400&h=300&fit=crop&q=80"
        case .ocean:
            // Ocean - beach scene (photo-1505142468610)
            return "https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=400&h=300&fit=crop&q=80"
        case .forest:
            // Forest - woodland (photo-1448375240586)
            return "https://images.unsplash.com/photo-1448375240586-882707db888b?w=400&h=300&fit=crop&q=80"
        case .mountains:
            // Mountains - alpine peaks (photo-1464822759023)
            return "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400&h=300&fit=crop&q=80"
        case .sunset:
            // Sunset - warm sky (photo-1518837695005)
            return "https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400&h=300&fit=crop&q=80"
        case .random:
            // Random - varied (photo-1506905925346)
            return "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop&q=80"
        }
    }
}

