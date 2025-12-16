//
//  WeatherAQIService.swift
//  MinimalClocksWidgetExtension
//
//  Created by Assistant on 01/01/25.
//

import Foundation
import CoreLocation

class WeatherAQIService {
    static let shared = WeatherAQIService()
    
    private let googleAPIKey: String
    
    private init() {
        // Read API key from GoogleService-Info.plist
        // Try widget bundle first, then main bundle
        var apiKey: String? = nil
        
        // Try widget extension bundle
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let key = plist["API_KEY"] as? String {
            apiKey = key
        }
        // Try main app bundle (if accessible via shared container)
        else if let mainBundle = Bundle(identifier: "in.hiteshsuthar.MinimalClocks"),
                 let path = mainBundle.path(forResource: "GoogleService-Info", ofType: "plist"),
                 let plist = NSDictionary(contentsOfFile: path),
                 let key = plist["API_KEY"] as? String {
            apiKey = key
        }
        
        // Fallback to hardcoded key (you should use environment variables or secure storage in production)
        self.googleAPIKey = apiKey ?? "AIzaSyBIVkjk-uIzpxQne_i5L-Dz9LV4PXMXAvA"
    }
    
    // MARK: - Location Manager
    private let locationManager = CLLocationManager()
    
    func requestLocation() async throws -> (latitude: Double, longitude: Double) {
        return try await withCheckedThrowingContinuation { continuation in
            let manager = CLLocationManager()
            manager.requestWhenInUseAuthorization()
            
            guard CLLocationManager.locationServicesEnabled() else {
                continuation.resume(throwing: WeatherAQIError.locationDisabled)
                return
            }
            
            let delegate = LocationDelegate { location, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let location = location {
                    continuation.resume(returning: (location.coordinate.latitude, location.coordinate.longitude))
                } else {
                    continuation.resume(throwing: WeatherAQIError.locationUnavailable)
                }
            }
            
            // Retain the delegate
            objc_setAssociatedObject(manager, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            manager.delegate = delegate
            manager.requestLocation()
        }
    }
    
    // MARK: - Weather API
    func fetchWeather(latitude: Double, longitude: Double) async throws -> CurrentWeather {
        let urlString = "https://weather.googleapis.com/v1/currentConditions:lookup?key=\(googleAPIKey)"
        
        guard let url = URL(string: urlString) else {
            throw WeatherAQIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "location": [
                "latitude": latitude,
                "longitude": longitude
            ],
            "languageCode": "en"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherAQIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorData["error"] as? [String: Any],
               let message = errorMessage["message"] as? String {
                throw WeatherAQIError.apiError(message)
            }
            throw WeatherAQIError.httpError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // The Weather API response structure
        struct WeatherAPIResponse: Codable {
            let location: WeatherLocation
            let current: CurrentWeather
        }
        
        let weatherResponse = try decoder.decode(WeatherAPIResponse.self, from: data)
        return weatherResponse.current
    }
    
    // MARK: - Air Quality API
    func fetchAirQuality(latitude: Double, longitude: Double) async throws -> AirQualityResponse {
        let urlString = "https://airquality.googleapis.com/v1/currentConditions:lookup?key=\(googleAPIKey)"
        
        guard let url = URL(string: urlString) else {
            throw WeatherAQIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "universalAqi": true,
            "location": [
                "latitude": latitude,
                "longitude": longitude
            ],
            "extraComputations": [
                "HEALTH_RECOMMENDATIONS",
                "DOMINANT_POLLUTANT_CONCENTRATION",
                "POLLUTANT_CONCENTRATION"
            ],
            "languageCode": "en"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherAQIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorData["error"] as? [String: Any],
               let message = errorMessage["message"] as? String {
                throw WeatherAQIError.apiError(message)
            }
            throw WeatherAQIError.httpError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let aqiResponse = try decoder.decode(AirQualityResponse.self, from: data)
        return aqiResponse
    }
    
    // MARK: - Combined Fetch
    func fetchWeatherAQIData(displayType: WeatherAQIDisplayType) async -> WeatherAQIData {
        do {
            let location = try await requestLocation()
            
            switch displayType {
            case .weather:
                let weather = try await fetchWeather(latitude: location.latitude, longitude: location.longitude)
                return WeatherAQIData(
                    date: Date(),
                    displayType: displayType,
                    weather: weather,
                    airQuality: nil,
                    location: location,
                    error: nil
                )
            case .airQuality:
                let airQuality = try await fetchAirQuality(latitude: location.latitude, longitude: location.longitude)
                return WeatherAQIData(
                    date: Date(),
                    displayType: displayType,
                    weather: nil,
                    airQuality: airQuality,
                    location: location,
                    error: nil
                )
            }
        } catch {
            return WeatherAQIData(
                date: Date(),
                displayType: displayType,
                weather: nil,
                airQuality: nil,
                location: nil,
                error: error.localizedDescription
            )
        }
    }
}

// MARK: - Location Delegate Helper
private class LocationDelegate: NSObject, CLLocationManagerDelegate {
    private let completion: (CLLocation?, Error?) -> Void
    
    init(completion: @escaping (CLLocation?, Error?) -> Void) {
        self.completion = completion
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completion(locations.first, nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion(nil, error)
    }
}

// MARK: - Errors
enum WeatherAQIError: LocalizedError {
    case locationDisabled
    case locationUnavailable
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .locationDisabled:
            return "Location services are disabled"
        case .locationUnavailable:
            return "Location is unavailable"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "API error: \(message)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

