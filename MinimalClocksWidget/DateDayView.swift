//
//  DateTimePickerView.swift
//  MinimalClocks
//
//  Created by Assistant
//

import SwiftUI

struct DateDayView: View {
    
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    let date: Date
    
    init(date: Date = Date.now) {
        self.date = date
    }
    
    private let darkBackground = Color(red: 0x34/255.0, green: 0x38/255.0, blue: 0x3B/255.0) // #34383B
    private let lightBackground = Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0) // #F8F8F8
    
    private var calendar: Calendar { Calendar.current }
    private var day: Int { calendar.component(.day, from: date) }
    private var month: String {
        let monthIndex = calendar.component(.month, from: date)
        let monthSymbols = calendar.monthSymbols
        return monthSymbols[monthIndex - 1]  // "November"
    }
    private var weekday: String {
        let weekdayIndex = calendar.component(.weekday, from: date)
        let weekdaySymbols = calendar.weekdaySymbols
        return weekdaySymbols[weekdayIndex - 1] // "Sunday"
    }
    
    var dateView: some View {
        // Day number - bold
        Text("\(day)") // e.g., "1"
            .font(Font.system(size: 80, weight: .bold, design: .rounded))
            .foregroundStyle(colorScheme == .light ? lightBackground : darkBackground)
            .fontWeight(.bold)
    }
    
    var weekDayView: some View {
        // Time display
        Text(weekday) // e.g., "Sunday"
            .font(Font.system(size: family == .systemSmall ? 24 : 40, weight: .semibold, design: .rounded))
            .foregroundStyle(colorScheme == .light ? darkBackground : lightBackground)
            .fontWeight(family == .systemSmall ? .medium : .light)
    }
    
    var monthView: some View {
        Text(month) // e.g., "November"
            .font(Font.system(size: family == .systemSmall ? 12 : 20, weight: .ultraLight, design: .rounded))
            .foregroundStyle(colorScheme == .light ? darkBackground : lightBackground)
            .fontWeight(family == .systemSmall ? .light : .medium)
    }
    
    
    var body: some View {
        if family == .systemSmall {
            VStack(spacing: 4) {
                dateView
                ZStack {
                    colorScheme == .light ? lightBackground : darkBackground
                    VStack(spacing: 0) {
                        monthView
                        weekDayView
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background {
                colorScheme == .light ? darkBackground : lightBackground
            }
        } else {
            HStack(spacing: 8) {
                // Left Section - Date
                dateView
                    .frame(maxWidth: 120)
                    .frame(maxHeight: .infinity)
                    .background { colorScheme == .light ? darkBackground : lightBackground }
                
                // Right Section - Date
                VStack(alignment: .leading, spacing: 0) {
                    weekDayView
                    monthView
                        .offset(y: -3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .background { colorScheme == .light ? lightBackground : darkBackground }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    DateDayView()
        .frame(width: 292, height: 141)
        .padding()
}
