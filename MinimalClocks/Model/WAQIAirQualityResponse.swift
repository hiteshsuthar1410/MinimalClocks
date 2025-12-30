//
//  WAQIAirQualityResponse.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 01/01/25.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - WAQI API Response Models
struct WAQIAirQualityResponse: Codable {
    let status: String
    let data: WAQIData?
}

struct WAQIData: Codable {
    let aqi: Int?
    let idx: Int?
    let attributions: [WAQIAttribution]?
    let city: WAQICity?
    let dominentpol: String?
    let iaqi: WAQIIndividualAQI?
    let time: WAQITime?
    let forecast: WAQIForecast?
}

struct WAQIAttribution: Codable {
    let url: String?
    let name: String?
    let logo: String?
}

struct WAQICity: Codable {
    let geo: [Double]? // [latitude, longitude]
    let name: String?
    let url: String?
}

struct WAQIIndividualAQI: Codable {
    let pm25: WAQIPollutantValue?
    let pm10: WAQIPollutantValue?
    let o3: WAQIPollutantValue?
    let no2: WAQIPollutantValue?
    let co: WAQIPollutantValue?
    let so2: WAQIPollutantValue?
}

struct WAQIPollutantValue: Codable {
    let v: Double // value
}

struct WAQITime: Codable {
    let s: String? // ISO8601 string
    let tz: String? // timezone
    let v: Int64? // Unix timestamp
}

struct WAQIForecast: Codable {
    let daily: WAQIDailyForecast?
}

struct WAQIDailyForecast: Codable {
    let pm25: [WAQIForecastDay]?
    let pm10: [WAQIForecastDay]?
    let o3: [WAQIForecastDay]?
    let no2: [WAQIForecastDay]?
}

struct WAQIForecastDay: Codable {
    let day: String?
    let avg: Int?
    let max: Int?
    let min: Int?
}

// MARK: - Helper Extension to Convert WAQI Response to App Format
extension WAQIData {
    /// Converts WAQI AQI value to AQIColor based on AQI scale
    func toAQIColor() -> AQIColor? {
        guard let aqi = aqi else { return nil }
        
        // AQI Color mapping based on US EPA AQI scale
        // 0-50: Good (Green)
        // 51-100: Moderate (Yellow)
        // 101-150: Unhealthy for Sensitive Groups (Orange)
        // 151-200: Unhealthy (Marron)
        // 201-300: Very Unhealthy (Red)
        // 301+: Hazardous (Purple)
        
        switch aqi {
        case 0...50:
            // Good - Green (#00E400)
            return AQIColor(red: 0.0, green: 228.0, blue: 0.0, alpha: 255.0)
        case 51...100:
            // Moderate - Yellow (#FFFF00)
            return AQIColor(red: 255.0, green: 255.0, blue: 0.0, alpha: 255.0)
        case 101...150:
            // Unhealthy for Sensitive Groups - Orange (#FF7E00)
            return AQIColor(red: 255.0, green: 126.0, blue: 0.0, alpha: 255.0)
        case 151...200:
            // Hazardous - Maroon (#7E0023)
            return AQIColor(red: 126.0, green: 0.0, blue: 35.0, alpha: 255.0)
        case 201...300:
            // Unhealthy - Red (#FF0000)
            return AQIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 255.0)
        default:
            // Very Unhealthy - Purple (#8F3F97)
            return AQIColor(red: 143.0, green: 63.0, blue: 151.0, alpha: 255.0)
        }
    }
    
    /// Converts WAQI AQI value to category string
    func toAQICategory() -> String {
        guard let aqi = aqi else { return "Unknown" }
        
        switch aqi {
        case 0...50:
            return "Good"
        case 51...100:
            return "Moderate"
        case 101...150:
            return "Unhealthy for Sensitive Groups"
        case 151...200:
            return "Unhealthy"
        case 201...300:
            return "Very Unhealthy"
        default:
            return "Hazardous"
        }
    }
    
    /// Converts WAQI time to Date
    func toDate() -> Date? {
        guard let time = time else { return nil }
        
        // Try parsing ISO8601 string first
        if let s = time.s {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: s) {
                return date
            }
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: s) {
                return date
            }
        }
        
        // Fallback to Unix timestamp
        if let v = time.v {
            return Date(timeIntervalSince1970: TimeInterval(v))
        }
        
        return nil
    }
}

