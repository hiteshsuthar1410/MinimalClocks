//
//  WeatherAQIModels.swift
//  MinimalClocksWidgetExtension
//
//  Created by Assistant on 01/01/25.
//

import Foundation

// MARK: - Weather Models
struct WeatherResponse: Codable {
    let location: WeatherLocation
    let current: CurrentWeather
}

struct WeatherLocation: Codable {
    let latitude: Double
    let longitude: Double
}

struct CurrentWeather: Codable {
    let temperature: Temperature
    let condition: String
    let humidity: Double
    let windSpeed: WindSpeed
    let windDirection: WindDirection
    let iconUri: String?
}

struct Temperature: Codable {
    let value: Double
    let unit: String
}

struct WindSpeed: Codable {
    let value: Double
    let unit: String
}

struct WindDirection: Codable {
    let value: Double
    let unit: String
}

// MARK: - Air Quality Models
struct AirQualityResponse: Codable {
    let dateTime: String
    let regionCode: String
    let indexes: [AQIIndex]
    let pollutants: [Pollutant]?
    let healthRecommendations: HealthRecommendations?
}

struct AQIIndex: Codable {
    let code: String
    let displayName: String
    let aqi: Int
    let aqiDisplay: String
    let color: AQIColor?
    let category: String
    let dominantPollutant: String?
}

struct AQIColor: Codable {
    let red: Double?
    let green: Double?
    let blue: Double?
    let alpha: Double?
}

struct Pollutant: Codable {
    let code: String
    let displayName: String
    let fullName: String
    let concentration: Concentration
}

struct Concentration: Codable {
    let value: Double
    let units: String
}

struct HealthRecommendations: Codable {
    let generalPopulation: String?
    let elderly: String?
    let lungDiseasePopulation: String?
    let heartDiseasePopulation: String?
    let athletes: String?
    let pregnantWomen: String?
    let children: String?
}

// MARK: - Combined Model for Widget
enum WeatherAQIDisplayType {
    case weather
    case airQuality
}

struct WeatherAQIData {
    let date: Date
    let displayType: WeatherAQIDisplayType
    let weather: CurrentWeather?
    let airQuality: AirQualityResponse?
    let location: (latitude: Double, longitude: Double)?
    let error: String?
    
    static func placeholder(displayType: WeatherAQIDisplayType) -> WeatherAQIData {
        WeatherAQIData(
            date: Date(),
            displayType: displayType,
            weather: nil,
            airQuality: nil,
            location: nil,
            error: nil
        )
    }
}

