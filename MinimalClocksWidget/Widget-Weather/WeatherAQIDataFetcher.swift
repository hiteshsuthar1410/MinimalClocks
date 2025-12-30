//
//  WeatherAQIDataFetcher.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 07/11/25.
//

import Combine
import CoreLocation
import SwiftUI

final class WeatherAQIDataFetcher: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var cancellables = Set<AnyCancellable>()
    private var completion: ((WeatherAQIEntry) -> Void)?
    
    func fetchData(for configuration: WeatherAQIIntentIntent, completion: @escaping (WeatherAQIEntry) -> Void) {
        self.completion = completion
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location failed: \(error.localizedDescription)")
        completion?(WeatherAQIEntry(date: Date(), temperature: nil, locationName: "Unknown", weatherCondition: nil, weatherIcon: nil, aqi: nil, aqiColor: nil, aqiCategory: nil, configuration: WeatherAQIIntentIntent()))
    }
    
    func fetchWeather(for location: CLLocation, locality: String, hours: Int = 24) -> AnyPublisher<GoogleWeatherApiHourlyResponse, Error> {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let apiKey = "AIzaSyC3AILT9K3agtHBcXxrdy7SsjSvxYjGdd0"
        let endpoint = "https://weather.googleapis.com/v1/forecast/hours:lookup?key=\(apiKey)&location.latitude=\(lat)&location.longitude=\(lon)&hours=\(hours)"
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(Util.handleOutput)
            .print()
            .decode(type: GoogleWeatherApiHourlyResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func fetchAQI(for location: CLLocation, locality: String, hours: Int = 24) -> AnyPublisher<WAQIAirQualityResponse, Error> {
        let token = "4737373e4db7dea6772719db309ca2b53877542d"
        
        // WAQI API supports both city name and lat/long format
        // Try city name first, fallback to lat/long format
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        // URL encode the locality for city name search
        let encodedLocality = locality.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? locality
        let cityEndpoint = "https://api.waqi.info/feed/\(encodedLocality)/?token=\(token)"
        
        // Try city name endpoint first
        guard let url = URL(string: cityEndpoint) else {
            // If city name fails, use lat/long format directly
            return fetchAQIWithLatLon(lat: lat, lon: lon, token: token)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                // Convert raw Data → String for printing
                if let jsonString = String(data: output.data, encoding: .utf8) {
                    print("🔵 RAW WAQI AQI RESPONSE JSON:\n\(jsonString)")
                }

                return try Util.handleOutput(output: output)
            }
            .decode(type: WAQIAirQualityResponse.self, decoder: JSONDecoder())
            .catch { error -> AnyPublisher<WAQIAirQualityResponse, Error> in
                // If city name search fails, try lat/long format
                print("⚠️ City name search failed, trying lat/long format: \(error.localizedDescription)")
                return self.fetchAQIWithLatLon(lat: lat, lon: lon, token: token)
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchAQIWithLatLon(lat: Double, lon: Double, token: String) -> AnyPublisher<WAQIAirQualityResponse, Error> {
        let latLonEndpoint = "https://api.waqi.info/feed/@\(lat),\(lon)/?token=\(token)"
        
        guard let url = URL(string: latLonEndpoint) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                if let jsonString = String(data: output.data, encoding: .utf8) {
                    print("🔵 RAW WAQI AQI RESPONSE JSON (lat/lon):\n\(jsonString)")
                }
                return try Util.handleOutput(output: output)
            }
            .decode(type: WAQIAirQualityResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

enum WidgetDataError: Error {
    case locationNotFound
    case placemarkNotFound
    case dateConversionFailed
    case temperatureConversionFailed
    case incompitableData
}

extension WeatherAQIDataFetcher {
    func fetchWeatherAsync(for location: CLLocation, locality: String) async throws -> GoogleWeatherApiHourlyResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchWeather(for: location, locality: locality)
                .sink { completion in
                    if case .failure(let error) = completion {
                        continuation.resume(throwing: error)
                    }
                } receiveValue: { response in
                    continuation.resume(returning: response)
                }
                .store(in: &self.cancellables)
        }
    }
    
    func fetchAQIAsync(for location: CLLocation, locality: String) async throws -> WAQIAirQualityResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchAQI(for: location, locality: locality)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(error)
                        continuation.resume(throwing: error)
                    }
                } receiveValue: { response in
                    continuation.resume(returning: response)
                }
                .store(in: &self.cancellables)
        }
    }
}
