//
//  WeatherAQIEntry.swift
//  MinimalClocks
//
//  Created by NovoTrax Dev1 on 07/11/25.
//


import WidgetKit
import SwiftUI
import CoreLocation
import Combine
import SwiftData

// MARK: - Model
struct WeatherAQIEntry: TimelineEntry {
    let date: Date
    let temperature: Double?
    let locationName: String?
    let weatherCondition: GoogleWeatherApiResponse.WeatherCondition?
    let weatherIcon: UIImage?
    // AQI Data
    let aqi: Double?
    let aqiColor: AQIColor?
    let aqiCategory: String?
    let configuration: WeatherAQIIntentIntent
    
    var isAQIMode: Bool {
        // AQI has index 1, Temperature has index 2
        configuration.WeatherWIdgetType.rawValue == 1
    }
}

@Model
class WeatherEntry {
    @Attribute(.unique) var date: Date
    var temperature: Double
    var locality: String

    init(date: Date, temperature: Double, locality: String) {
        self.date = date
        self.temperature = temperature
        self.locality = locality
    }
}

// MARK: - Provider
struct WeatherAQIProvider: IntentTimelineProvider {
    
    let repo = WeatherAQIRepository()

    func placeholder(in context: Context) -> WeatherAQIEntry {
        WeatherAQIEntry(date: Date(), temperature: 27.0, locationName: "Jaipur", weatherCondition: nil, weatherIcon: nil, aqi: nil, aqiColor: nil, aqiCategory: nil, configuration: WeatherAQIIntentIntent())
    }

    func getSnapshot(for configuration: WeatherAQIIntentIntent, in context: Context, completion: @escaping (WeatherAQIEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(for configuration: WeatherAQIIntentIntent, in context: Context, completion: @escaping (Timeline<WeatherAQIEntry>) -> Void) {
        
        let locationData = AppGroupStorage().loadLocationFromSharedDefaults()
        guard let locality = locationData.locality else {
            return
        }

        let refresh = Calendar.current.date(byAdding: .minute, value: 60, to: Date())!
        let failedEntry: [WeatherAQIEntry] = [
            WeatherAQIEntry(date: .now,
                            temperature: 0,
                            locationName: "Failed to load data",
                            weatherCondition: nil,
                            weatherIcon: nil,
                            aqi: nil,
                            aqiColor: nil,
                            aqiCategory: nil,
                            configuration: configuration)
        ]
        let failedTimeline = Timeline(entries: failedEntry, policy: .after(refresh))

        Task {
            do {
                // Check widget type from configuration (AQI has rawValue 1)
                let isAQI: Bool = configuration.WeatherWIdgetType.rawValue == 1
                
                if isAQI {
                    // Fetch AQI data from WAQI API
                    guard let aqiResponse = await repo.fetchAndSaveLatestHourlyAQI() else {
                        completion(failedTimeline)
                        return
                    }

                    guard let waqiData = aqiResponse.data,
                          let aqi = waqiData.aqi else {
                        completion(failedTimeline)
                        return
                    }

                    // Get date from WAQI response or use current date
                    let date = waqiData.toDate() ?? Date()
                    
                    // Get location name from WAQI city name or use locality
                    let locationName = waqiData.city?.name ?? locality
                    
                    // Convert WAQI AQI to app format
                    let aqiColor = waqiData.toAQIColor()
                    let aqiCategory = waqiData.toAQICategory()
                    
                    // Create a single entry for current AQI (WAQI provides current data, not hourly)
                    let entry = WeatherAQIEntry(
                        date: date,
                        temperature: nil,
                        locationName: locationName,
                        weatherCondition: nil,
                        weatherIcon: nil,
                        aqi: Double(aqi),
                        aqiColor: aqiColor,
                        aqiCategory: aqiCategory,
                        configuration: configuration
                    )

                    let timeline = Timeline(entries: [entry], policy: .after(refresh))
                    completion(timeline)
                    
                } else {
                    // Fetch hourly weather
                    guard let response = await repo.fetchAndSaveLatestHourlyWeather() else {
                        completion(failedTimeline)
                        return
                    }

                    guard let hoursForecast = response.forecastHours else {
                        completion(failedTimeline)
                        return
                    }

                    // Build entries safely with image preloading
                    let entries: [WeatherAQIEntry] = try await withThrowingTaskGroup(of: WeatherAQIEntry.self) { group in
                        var entryArray: [WeatherAQIEntry] = []
                        
                        for hourForecast in hoursForecast {
                            group.addTask {
                                guard let date = hourForecast.displayDateTime?.toDate() else {
                                    throw WidgetDataError.dateConversionFailed
                                }
                                guard let temperature = hourForecast.temperature?.degrees else {
                                    throw WidgetDataError.temperatureConversionFailed
                                }
                                
                                // Preload weather icon
                                let weatherIcon = await Util.loadImage(from: hourForecast.weatherCondition?.iconBaseUri ?? "")
                                
                                return WeatherAQIEntry(
                                    date: date,
                                    temperature: temperature,
                                    locationName: locality,
                                    weatherCondition: hourForecast.weatherCondition,
                                    weatherIcon: weatherIcon,
                                    aqi: nil,
                                    aqiColor: nil,
                                    aqiCategory: nil,
                                    configuration: configuration
                                )
                            }
                        }
                        
                        for try await entry in group {
                            entryArray.append(entry)
                        }
                        
                        return entryArray.sorted { $0.date < $1.date }
                    }

                    // Ensure at least one entry
                    guard !entries.isEmpty else {
                        completion(failedTimeline)
                        return
                    }

                    // Success timeline
                    let timeline = Timeline(entries: entries, policy: .after(refresh))
                    completion(timeline)
                }

            } catch {
                print("❌ Timeline building failed: \(error)")
                completion(failedTimeline)
            }
        }
    }
}

struct WeatherAQIWidget: Widget {
    let kind: String = "WeatherAQIWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: WeatherAQIIntentIntent.self, provider: WeatherAQIProvider()) { entry in
            WeatherAQIWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .containerBackgroundRemovable()
        .configurationDisplayName("Local Weather / AQI")
        .description("See current air quality or temperature near you.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}
