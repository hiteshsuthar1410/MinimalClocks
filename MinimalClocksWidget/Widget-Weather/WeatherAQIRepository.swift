//
//  WeatherAQIRepository.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 18/11/25.
//


import Foundation
import Combine
import CoreLocation

final class WeatherAQIRepository {

    private let storage = AppGroupStorage()
    private let weatherAQIDataFetcher = WeatherAQIDataFetcher()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Save Data to App Group
    func saveHourlyWeather(_ data: GoogleWeatherApiHourlyResponse) {
        do {
            try storage.save(data, forKey: "hourly_weather_response")
        } catch {
            print("❌ Failed to save hourly weather: \(error)")
        }
    }

    // MARK: - Load Saved Data
    func loadSavedHourlyWeather() -> GoogleWeatherApiHourlyResponse? {
        do {
            return try storage.load(GoogleWeatherApiHourlyResponse.self,
                                    forKey: "hourly_weather_response")
        } catch {
            print("❌ Failed to load saved hourly weather: \(error)")
            return nil
        }
    }

    // MARK: - Save AQI Data to App Group
    func saveHourlyAQI(_ data: WAQIAirQualityResponse) {
        do {
            try storage.save(data, forKey: "hourly_aqi_response")
        } catch {
            print("❌ Failed to save hourly AQI: \(error)")
        }
    }

    // MARK: - Load Saved AQI Data
    func loadSavedHourlyAQI() -> WAQIAirQualityResponse? {
        do {
            return try storage.load(WAQIAirQualityResponse.self,
                                    forKey: "hourly_aqi_response")
        } catch {
            print("❌ Failed to load saved hourly AQI: \(error)")
            return nil
        }
    }
    
    // MARK: - Fetch From API and Save
    
    func fetchAndSaveLatestHourlyWeather() async -> GoogleWeatherApiHourlyResponse? {
        let locationData = AppGroupStorage().loadLocationFromSharedDefaults()
        
        guard let location = locationData.location,
              let locality = locationData.locality else {
            return nil
        }

        do {
            let response = try await weatherAQIDataFetcher.fetchWeatherAsync(for: location, locality: locality)
            saveHourlyWeather(response)
            return response

        } catch {
            return loadSavedHourlyWeather()
        }
    }
    
    func fetchAndSaveLatestHourlyAQI() async -> WAQIAirQualityResponse? {
        let locationData = AppGroupStorage().loadLocationFromSharedDefaults()
        
        guard let location = locationData.location,
              let locality = locationData.locality else {
            return nil
        }

        do {
            let response = try await weatherAQIDataFetcher.fetchAQIAsync(for: location, locality: locality)
            saveHourlyAQI(response)
            return response

        } catch {
            return loadSavedHourlyAQI()
        }
    }
    
    // MARK: - Fetch with Specific Location (for location changes)
    func fetchAndSaveLatestHourlyWeather(for location: CLLocation, locality: String) async -> GoogleWeatherApiHourlyResponse? {
        do {
            let response = try await weatherAQIDataFetcher.fetchWeatherAsync(for: location, locality: locality)
            saveHourlyWeather(response)
            return response
        } catch {
            print("❌ Failed to fetch weather for location: \(error)")
            return loadSavedHourlyWeather()
        }
    }
    
    func fetchAndSaveLatestHourlyAQI(for location: CLLocation, locality: String) async -> WAQIAirQualityResponse? {
        do {
            let response = try await weatherAQIDataFetcher.fetchAQIAsync(for: location, locality: locality)
            saveHourlyAQI(response)
            return response
        } catch {
            print("❌ Failed to fetch AQI for location: \(error)")
            return loadSavedHourlyAQI()
        }
    }
}
