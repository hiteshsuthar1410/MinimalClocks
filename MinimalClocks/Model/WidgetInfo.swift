//
//  MCWidgetInfo.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 25/01/25.
//

import Foundation
import SwiftUI

// MARK: - Widget Info Model
struct MCWidgetInfo: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let benefits: [String]
    let icon: String
    let color: Color
    let widgetType: WidgetType
    
    enum WidgetType: CaseIterable {
        case dayProgressCircleCompleted
        case dayProgressCircleRemaining
        case dayProgressBarCompleted
        case dayProgressBarRemaining
        case motivationalQuote
        case dayDateMonth
        case dateTimePicker
        case weatherTemperature
        case weatherAQI
    }
}

extension MCWidgetInfo {
    static let allWidgets: [MCWidgetInfo] = [
        MCWidgetInfo(
            title: "Day Progress Circle (Completed)",
            description: "Track your daily progress with a beautiful circular progress indicator that shows how much of your day has been completed.",
            benefits: [
                "Stay focused by visualizing your progress",
                "Maintain awareness of your daily rhythm",
                "Prioritize tasks with clear time insights",
                "Boost motivation with real-time feedback"
            ],
            icon: "circle.fill",
            color: .indigo,
            widgetType: .dayProgressCircleCompleted
        ),
        MCWidgetInfo(
            title: "Day Progress Circle (Remaining)",
            description: "See how much time remains in your day with a circular progress indicator that shows remaining time.",
            benefits: [
                "Keep track of remaining time to stay on task",
                "Plan your day effectively with visual cues",
                "Enhance focus by seeing time left",
                "Stay motivated with a clear countdown"
            ],
            icon: "circle.dotted",
            color: .indigo,
            widgetType: .dayProgressCircleRemaining
        ),
        MCWidgetInfo(
            title: "Day Progress Bar (Completed)",
            description: "Monitor your day's progress with an elegant horizontal progress bar that fills as time passes.",
            benefits: [
                "Quickly assess your progress at a glance",
                "Stay aware of your time usage",
                "Prioritize activities with clear progress",
                "Maintain daily momentum"
            ],
            icon: "chart.bar.fill",
            color: .orange,
            widgetType: .dayProgressBarCompleted
        ),
        MCWidgetInfo(
            title: "Day Progress Bar (Remaining)",
            description: "Track remaining time in your day with a horizontal progress bar that shows time left.",
            benefits: [
                "Visualize time left to stay on track",
                "Plan and prioritize remaining tasks",
                "Enhance productivity with clear time awareness",
                "Keep motivated with a simple countdown"
            ],
            icon: "chart.bar.xaxis",
            color: .orange,
            widgetType: .dayProgressBarRemaining
        ),
        MCWidgetInfo(
            title: "Motivational Quote",
            description: "Get inspired throughout your day with beautiful quotes paired with stunning nature photography.",
            benefits: [
                "Boost your motivation daily",
                "Cultivate a positive mindset",
                "Enjoy moments of inspiration",
                "Stay mindful and focused"
            ],
            icon: "quote.bubble.fill",
            color: .green,
            widgetType: .motivationalQuote
        ),
        MCWidgetInfo(
            title: "Day Date Month",
            description: "A clean, minimalist date display showing the weekday, day number, and abbreviated month in an elegant compact format.",
            benefits: [
                "Stay oriented with the current date at a glance",
                "Quickly reference day, date, and month",
                "Minimalist design that fits any home screen",
                "Updates automatically once per day at midnight"
            ],
            icon: "calendar",
            color: .blue,
            widgetType: .dayDateMonth
        ),
        MCWidgetInfo(
            title: "Weather Temperature",
            description: "Stay informed about current weather conditions with real-time temperature, location, and weather status displayed in a beautiful minimalist design.",
            benefits: [
                "Monitor current temperature at a glance",
                "See weather conditions with intuitive icons",
                "Get location-based weather updates",
                "Plan your day with accurate weather information"
            ],
            icon: "thermometer.sun.fill",
            color: .orange,
            widgetType: .weatherTemperature
        ),
        MCWidgetInfo(
            title: "Air Quality Index (AQI)",
            description: "Track air quality in your area with real-time AQI readings, color-coded indicators, and health recommendations to help you make informed decisions about outdoor activities.",
            benefits: [
                "Monitor air quality for your health",
                "Get color-coded AQI indicators",
                "See health recommendations based on AQI levels",
                "Make informed decisions about outdoor activities"
            ],
            icon: "aqi.medium",
            color: .green,
            widgetType: .weatherAQI
        )]
    
    static func info(for widgetType: WidgetType) -> MCWidgetInfo? {
        return allWidgets.first { $0.widgetType == widgetType }
    }
}
