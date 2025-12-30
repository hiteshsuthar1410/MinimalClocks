//
//  Haptic.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 31/12/25.
//

import UIKit


enum Haptic {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
