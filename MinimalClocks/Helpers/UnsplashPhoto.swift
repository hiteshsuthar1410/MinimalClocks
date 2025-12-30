//
//  UnsplashPhoto.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 19/01/25.
//

import Foundation
import UIKit

// Structs to decode the Unsplash API response
struct UnsplashPhoto: Decodable {
    let id: String
    let description: String?
    let altDescription: String?
    let urls: Urls?
    let user: UnsplashUser?
    let createdAt: String? // ISO8601 format date
}

extension UnsplashPhoto {
    static var preview: UnsplashPhoto {
        UnsplashPhoto(
            id: "101",
            description: "No description",
            altDescription: "A blurry photo of trees in a forest",
            urls: Urls(regular: "https://images.unsplash.com/photo-1736941299356-a863f0d9081d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w2OTg2NDV8MHwxfHJhbmRvbXx8fHx8fHx8fDE3MzcyODIzODR8&ixlib=rb-4.0.3&q=80&w=1080"),
            user: UnsplashUser(name: "Ingmar H", username: "fujiforest"),
            createdAt: "2025-01-15T11:41:50Z"
        )
    }
}

struct Urls: Decodable {
    let regular: String
}

struct UnsplashUser: Decodable {
    let name: String
    let username: String
}
