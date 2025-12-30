//
//  String+.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 06/02/25.
//

import Foundation
extension String {
    // This computed property uses a regex to validate that the string is a properly formatted email address.
    var isValidEmail: Bool {
        let emailRegEx = "(?:[A-Z0-9a-z._%+-]+)@(?:[A-Za-z0-9-]+\\.)+[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
}
