//
//  Date+.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 20/01/25.
//

import Foundation
extension Date {
    static var tomorrowMidnight: Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        return calendar.startOfDay(for: tomorrow)
    }
}
