//
//  User.swift
//  MinimalClocks
//
//  Created by NovoTrax Dev1 on 18/01/25.
//

import Foundation
struct User: Codable, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var sentQuoteIDs: [String]
    var createdDate: Date
}
