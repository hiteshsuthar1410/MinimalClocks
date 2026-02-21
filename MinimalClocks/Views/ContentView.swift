//
//  ContentView.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 11/01/25.
//

import SwiftData
import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
    @State var quotes = [Quote]()
    @State var imageURL: URL?
    @State var motivationalQuoteWidgetBGImage: UIImage?
    @State var widgetPreviewEntry: WeatherAQIEntry?
    @State var aqiPreviewEntry: WeatherAQIEntry?
    @State var showSheet: ContentViewSheet? = nil
    
    enum ContentViewSheet: Identifiable {
        
        case profile
        case widgetInfo(widgetType: MCWidgetInfo.WidgetType)
        
        var id: String {
            switch self {
            case .profile:
                return "profile"
            case .widgetInfo(let widgetType):
                return "widgetInfo-\(widgetType)"
            }
        }
    }
    
    let repo = WeatherAQIRepository()
    let locationHandler = LocationHandler()
    var columns = [
        GridItem(.flexible()), // First column
        GridItem(.flexible())  // Second column
    ]
    var column = [
        GridItem(.flexible()), // First column
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    
                    // Productivity Section
                    productivitySection
                    
                    // Motivational Quote Section
                    motivationalQuoteSection
                    
                    // Date and Time Section
                    dateAndTimeSection
                    
                    // Weather Section
                    weatherSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .navigationTitle("Minimal Clocks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    profileToolbarButton
                        .hidden()
                }
            }
        }
        .task {
            authenticateUser()
            locationHandler.fetchLocation()
            await loadMotivationalQuoteBackground()
            do {
                try await QuoteService.shared.refreshQuotesIfNeeded(context: context, threshold: 10)
            } catch {
                print("Quote refresh failed: \(error)")
            }
            
            // Load weather and AQI data
            await loadWeatherAndAQIData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LocationDidChange"))) { _ in
            // Refresh weather and AQI data when location changes
            Task {
                await loadWeatherAndAQIData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BackgroundCategoryDidChange"))) { _ in
            // Refresh background image when category changes
            Task {
                await loadMotivationalQuoteBackground()
            }
        }
        .sheet(item: $showSheet) { sheet in
            switch sheet {
            case .profile:
                ProfileView()
                    .presentationBackgroundInteraction(.disabled)
                    .presentationBackground(.regularMaterial)
                //                    .interactiveDismissDisabled()
                
                
            case .widgetInfo(let widgetInfo):
                WidgetExplanationSheetView(widgetInfo: MCWidgetInfo.info(for: widgetInfo)!)
                    .interactiveDismissDisabled(true)
            }
        }
    }
    
    func getTimeline(for configuration: WeatherAQIIntentIntent, completion: @escaping (Timeline<WeatherAQIEntry>) -> Void) {
        
        let locationData = AppGroupStorage().loadLocationFromSharedDefaults()
        guard let _ = locationData.location,
              let locality = locationData.locality else {
            return
        }
        
        let refresh = Calendar.current.date(byAdding: .minute, value: 60, to: Date())!
        let failedEntry = [
            WeatherAQIEntry(date: .now,
                            temperature: 0,
                            locationName: "Failed to load data",
                            weatherCondition: nil,
                            weatherIcon: nil,
                            aqi: nil,
                            aqiColor: nil,
                            aqiCategory: nil,
                            configuration: WeatherAQIIntentIntent())
        ]
        let failedTimeline = Timeline(entries: failedEntry, policy: .after(refresh))
        
        Task {
            do {
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
                
            } catch {
                print("❌ Timeline building failed: \(error)")
                completion(failedTimeline)
            }
        }
    }
    
}

#Preview {
    ContentView()
}

