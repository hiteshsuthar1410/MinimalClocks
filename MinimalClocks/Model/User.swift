//
//  User.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 18/01/25.
//

import Foundation
struct User: Codable, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var sentQuoteIDs: [String]
    var createdDate: Date
}
