//
//  GoogleAirQualityResponse.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 07/11/25.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Air Quality API Response Models
struct GoogleAirQualityHourlyResponse: Codable {
    let hoursInfo: [GoogleAirQualityHourInfo]?
    let regionCode: String?
    let nextPageToken: String?
}

struct GoogleAirQualityHourInfo: Codable {
    let dateTime: String
    let indexes: [AQIIndex]?
    
    /// Converts the ISO8601 dateTime string to a Date object
    func toDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateTime) ?? ISO8601DateFormatter().date(from: dateTime)
    }
}

struct AQIIndex: Codable {
    let code: String
    let displayName: String
    let aqi: Double
    let aqiDisplay: String
    let color: AQIColor?
    let category: String
    let dominantPollutant: String?
}

struct AQIColor: Codable {
    let red: Double
    let green: Double
    let blue: Double?
    let alpha: Double?
    
    var uiColor: UIColor {
        UIColor(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue ?? 0) / 255.0,
            alpha: CGFloat(alpha ?? 255) / 255.0
        )
    }
    
    var swiftUIColor: Color {
        Color(
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue ?? 0) / 255.0
        )
    }
}

// MARK: - Weather Condition Type Enum
enum WeatherConditionType: String {
    case clear = "CLEAR"
    case rainShowers = "RAIN_SHOWERS"
    case lightRain = "LIGHT_RAIN"
    case cloudy = "CLOUDY"
    case partlyCloudy = "PARTLY_CLOUDY"
    case mostlyClear = "MOSTLY_CLEAR"
    case fog = "FOG"
    case haze = "HAZE"
    case smoke = "SMOKE"
    case dust = "DUST"
    case snow = "SNOW"
    case sleet = "SLEET"
    case hail = "HAIL"
    case freezingRain = "FREEZING_RAIN"
    case thunderstorms = "THUNDERSTORMS"
    case windy = "WINDY"
    case tornado = "TORNADO"
    case hurricane = "HURRICANE"
    case tropicalStorm = "TROPICAL_STORM"
    case blizzard = "BLIZZARD"
    case sandstorm = "SANDSTORM"
    case volcanicAsh = "VOLCANIC_ASH"
    case unknownPrecipitation = "UNKNOWN_PRECIPITATION"
    case unknown
    
    init(from string: String) {
        self = WeatherConditionType(rawValue: string) ?? .unknown
    }
    
    var sfSymbolName: String {
        switch self {
        case .clear:
            return "sun.max.fill"
        case .rainShowers:
            return "cloud.rain.fill"
        case .lightRain:
            return "cloud.drizzle.fill"
        case .cloudy:
            return "cloud.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .mostlyClear:
            return "sun.max.fill"
        case .fog:
            return "cloud.fog.fill"
        case .haze:
            return "sun.haze.fill"
        case .smoke:
            return "smoke.fill"
        case .dust:
            return "aqi.low"
        case .snow:
            return "cloud.snow.fill"
        case .sleet:
            return "cloud.sleet.fill"
        case .hail:
            return "cloud.hail.fill"
        case .freezingRain:
            return "cloud.sleet.fill"
        case .thunderstorms:
            return "cloud.bolt.fill"
        case .windy:
            return "wind"
        case .tornado:
            return "tornado"
        case .hurricane:
            return "hurricane"
        case .tropicalStorm:
            return "tropicalstorm"
        case .blizzard:
            return "cloud.snow.fill"
        case .sandstorm:
            return "aqi.low"
        case .volcanicAsh:
            return "smoke.fill"
        case .unknownPrecipitation:
            return "cloud.rain.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    /// Returns the appropriate SF Symbol name considering day/night time
    func sfSymbolName(for date: Date) -> String {
        // For clear and mostly clear conditions, use moon at night
        if self == .clear || self == .mostlyClear {
            return isNightTime(date: date) ? "moon.fill" : "sun.max.fill"
        }
        // For partly cloudy, use moon with cloud at night
        if self == .partlyCloudy {
            return isNightTime(date: date) ? "cloud.moon.fill" : "cloud.sun.fill"
        }
        return sfSymbolName
    }
    
    /// Determines if the given date is during night time (6 PM to 6 AM)
    private func isNightTime(date: Date) -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        return hour >= 18 || hour < 6
    }
    
    /// Returns gradient colors for the weather condition
    func gradientColors(for colorScheme: ColorScheme) -> (start: Color, end: Color) {
        let isDark = colorScheme == .dark
        
        switch self {
        case .clear, .mostlyClear:
            // Sunny: Vibrant yellow/orange gradient
            return isDark 
                ? (Color.black, Color(red: 0.5, green: 0.4, blue: 0.15))
                : (Color.white, Color(red: 1.0, green: 0.9, blue: 0.5))
                
        case .partlyCloudy:
            // Partly cloudy: Vibrant yellow
            return isDark
                ? (Color.black, Color(red: 0.4, green: 0.35, blue: 0.2))
                : (Color.white, Color(red: 1.0, green: 0.95, blue: 0.7))
                
        case .rainShowers, .lightRain, .freezingRain, .unknownPrecipitation:
            // Rain: Vibrant blue
            return isDark
                ? (Color.black, Color(red: 0.2, green: 0.3, blue: 0.5))
                : (Color.white, Color(red: 0.7, green: 0.85, blue: 1.0))
                
        case .snow, .sleet, .hail, .blizzard:
            // Snow: Vibrant cool blue (colder)
            return isDark
                ? (Color.black, Color(red: 0.15, green: 0.25, blue: 0.45))
                : (Color.white, Color(red: 0.65, green: 0.8, blue: 1.0))
                
        case .thunderstorms:
            // Thunderstorms: Vibrant purple/blue
            return isDark
                ? (Color.black, Color(red: 0.35, green: 0.25, blue: 0.5))
                : (Color.white, Color(red: 0.6, green: 0.65, blue: 0.9))
                
        case .cloudy, .fog, .haze:
            // Cloudy/Fog: Medium grey
            return isDark
                ? (Color.black, Color(white: 0.35))
                : (Color.white, Color(white: 0.75))
                
        case .smoke, .dust, .sandstorm, .volcanicAsh:
            // Smoke/Dust: Vibrant brown/grey
            return isDark
                ? (Color.black, Color(red: 0.4, green: 0.35, blue: 0.3))
                : (Color.white, Color(red: 0.9, green: 0.85, blue: 0.75))
                
        case .windy, .tornado, .hurricane, .tropicalStorm:
            // Wind/Storm: Vibrant grey-blue
            return isDark
                ? (Color.black, Color(red: 0.25, green: 0.3, blue: 0.4))
                : (Color.white, Color(red: 0.75, green: 0.8, blue: 0.9))
                
        case .unknown:
            // Unknown: Neutral grey
            return isDark
                ? (Color.black, Color(white: 0.3))
                : (Color.white, Color(white: 0.85))
        }
    }
}

struct GoogleWeatherApiHourlyResponse: Codable {
    let forecastHours: [GoogleWeatherApiResponse]?
}

struct GoogleWeatherApiResponse: Codable {
    let displayDateTime: DisplayDateTime?
    let weatherCondition: WeatherCondition?
    let temperature: MeasurementData?
    let timeZone: Timezone?
    

    struct MeasurementData: Codable {
        let degrees: Double?
        let unit: String?
    }

    struct Timezone: Codable {
        let id: String?
    }
    
    struct WeatherCondition: Codable {
        let iconBaseUri: String
        let description: Description
        let type: String
        
        var conditionType: WeatherConditionType {
            WeatherConditionType(from: type)
        }
    }

    struct Description: Codable {
        let text: String
        let languageCode: String
    }
    
    struct DisplayDateTime: Codable {
        let year: Int
        let month: Int
        let day: Int
        let hours: Int
        let utcOffset: String

        /// Converts the JSON values into a native `Date` object
        func toDate() -> Date? {
            // Extract offset in seconds (e.g., "-28800s" → -28800)
            let offsetSeconds = Int(utcOffset.replacingOccurrences(of: "s", with: "")) ?? 0
            
            // Build date components
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            components.hour = hours

            // Create date using UTC calendar
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(secondsFromGMT: offsetSeconds) ?? .current
            
            return calendar.date(from: components)
        }
    }
}
