//
//  ContentView.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 11/01/25.
//

import Combine
import CoreLocation
import Firebase
import FirebaseAuth
import Kingfisher
import SwiftData
import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
    @State private var quotes = [Quote]()
    @State private var imageURL: URL?
    @State private var motivationalQuoteWidgetBGImage: UIImage?
    @State private var widgetPreviewEntry: WeatherAQIEntry?
    @State private var aqiPreviewEntry: WeatherAQIEntry?
    @State private var showSheet: ContentViewSheet? = nil
    
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
    
    private let repo = WeatherAQIRepository()
    private let locationHandler = LocationHandler()
    private var columns = [
        GridItem(.flexible()), // First column
        GridItem(.flexible())  // Second column
    ]
    private var column = [
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
                    Button {
                        showSheet = .profile
                    } label: {
                        Group {
                            if let photoURLString = UserManager.shared.getUserPhotoURL(), let photoURL = URL(string: photoURLString) {
                                KFImage(photoURL)
                                    .placeholder {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFill()
                                    }
                                    .resizing(referenceSize: CGSize(width: 64, height: 64), mode: .aspectFill)
                                    .cacheMemoryOnly()
                                    .fade(duration: 0.25)
                                    .onFailure { error in
                                        print("Failed to load user profile image: \(error)")
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
            }
        }
        .task {
            authenticateUser()
            do { motivationalQuoteWidgetBGImage = try await UnsplashPhotoService.shared().fetchRandomPhoto(query: "Nature").0 } catch {}
            do {
                try await QuoteService.shared.refreshQuotesIfNeeded(context: context, threshold: 10)
            } catch {
                print("Quote refresh failed: \(error)")
            }
            locationHandler.fetchLocation()
            
            // Load weather and AQI data
            await loadWeatherAndAQIData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LocationDidChange"))) { _ in
            // Refresh weather and AQI data when location changes
            Task {
                await loadWeatherAndAQIData()
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
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(1...8, id: \.self) { index in
                        PillButtonView()
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Productivity Section
    private var productivitySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Productivity")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            // Grid of widget buttons
            LazyVGrid(columns: columns, spacing: 16) {
                WidgetButtonView {
                    DayProgressCircleView(date: Date(), progressType: .completed)
                } action: {
                    showWidgetInfo(.dayProgressCircleCompleted)
                }
                
                WidgetButtonView {
                    DayProgressCircleView(date: Date(), progressType: .remaining)
                } action: {
                    showWidgetInfo(.dayProgressCircleRemaining)
                }
            }
            
            // Full-width progress bars
            VStack(spacing: 16) {
                WidgetButtonView {
                    DayProgressBarView(date: Date(), progressType: .completed)
                } action: {
                    showWidgetInfo(.dayProgressBarCompleted)
                }
                
                WidgetButtonView {
                    DayProgressBarView(date: Date(), progressType: .remaining)
                } action: {
                    showWidgetInfo(.dayProgressBarRemaining)
                }
            }
        }
    }
    // MARK: - Date and Time Section
    private var dateAndTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date and Time")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
                
                WidgetButtonView {
                    DateDayView()
                } action: {
                    showWidgetInfo(.dayDateMonth)
                }
        }
    }
    
    // MARK: - Motivational Quote Section
    private var motivationalQuoteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Motivational Quote")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            WidgetButtonView {
                MotivationalQuoteView(entry: MotivationalQuoteWidgetEntry.init(date: Date(), quote: QuoteModel.preview, unsplashPhoto: UnsplashPhoto.preview, image: motivationalQuoteWidgetBGImage, shouldUpdate: false))
            } action: {
                showWidgetInfo(.motivationalQuote)
            }
        }
    }
    
    // MARK: - Weather Section
    private var weatherSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weather / AQI")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            // Grid for Temperature and AQI widgets
            HStack(spacing: 16) {
                // Temperature Widget
                WidgetButtonView {
                    if let entry = widgetPreviewEntry {
                        WeatherAQIWidgetView(entry: entry)
                    } else {
                        WeatherAQIWidgetView(entry: WeatherAQIEntry(
                            date: Date(),
                            temperature: nil,
                            locationName: "Loading...",
                            weatherCondition: nil,
                            weatherIcon: nil,
                            aqi: nil,
                            aqiColor: nil,
                            aqiCategory: nil,
                            configuration: {
                                let config = WeatherAQIIntentIntent()
                                config.WeatherWIdgetType = .temperature
                                return config
                            }()
                        ))
                    }
                } action: {
                    showWidgetInfo(.weatherTemperature)
                }
                
                // AQI Widget
                WidgetButtonView {
                    if let entry = aqiPreviewEntry {
                        WeatherAQIWidgetView(entry: entry)
                    } else {
                        WeatherAQIWidgetView(entry: WeatherAQIEntry(
                            date: Date(),
                            temperature: nil,
                            locationName: "Loading...",
                            weatherCondition: nil,
                            weatherIcon: nil,
                            aqi: nil,
                            aqiColor: nil,
                            aqiCategory: nil,
                            configuration: {
                                let config = WeatherAQIIntentIntent()
                                config.WeatherWIdgetType = .aQI
                                return config
                            }()
                        ))
                    }
                } action: {
                    showWidgetInfo(.weatherAQI)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func showWidgetInfo(_ widgetType: MCWidgetInfo.WidgetType) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        showSheet = .widgetInfo(widgetType: widgetType)
    }
    
    private func authenticateUser() {
        if let user = Auth.auth().currentUser {
            user.getIDTokenResult { result, error in
                if error != nil {
                    debugPrint(error as Any, terminator: "\n")
                }
                debugPrint(result as Any, terminator: "\n")
            }
        } else {
            debugPrint("\ncurrent user is nil")
        }
    }
}

class LocationHandler: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    func fetchLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print(state)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            var appGroupStorage = AppGroupStorage()
            Task {
                do {
                    let placemark = try await Util.getPlacemarkFrom(location: location)
                    if let locality = placemark.locality {
                        appGroupStorage.saveLocationToSharedDefaults(location: location, city: locality)
                    }
                } catch {
                    return
                }
            }
        }
    }

}

extension ContentView {
    func loadWeatherAndAQIData() async {
        // Load weather and AQI data
        async let weatherTask = loadLatestWeatherEntry()
        async let aqiTask = loadLatestAQIEntry()
        
        widgetPreviewEntry = await weatherTask
        aqiPreviewEntry = await aqiTask
        
        // If AQI data is not available, try to fetch it
        if aqiPreviewEntry == nil {
            _ = await repo.fetchAndSaveLatestHourlyAQI()
            aqiPreviewEntry = await loadLatestAQIEntry()
        } else {
            print("Successfully fetched AQI Data")
        }
    }
    
    func loadLatestWeatherEntry() async -> WeatherAQIEntry? {
        let storage = AppGroupStorage()
        let locationData = storage.loadLocationFromSharedDefaults()

        guard let locality = locationData.locality else {
            print("Location Fetch Failed from app group storage:")
            return nil
        }
        
        guard let hoursForecast = repo.loadSavedHourlyWeather()?.forecastHours else {
            return nil
        }
        
        do {
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
                            configuration: WeatherAQIIntentIntent()
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
                return nil
            }
            
            let target = Date() // or any other date
            
            let closest = entries.min {
                abs($0.date.timeIntervalSince(target)) < abs($1.date.timeIntervalSince(target))
            }
            
            return closest
        } catch {
            return nil
        }
    }
    
    func loadLatestAQIEntry() async -> WeatherAQIEntry? {
        let storage = AppGroupStorage()
        let locationData = storage.loadLocationFromSharedDefaults()

        guard let locality = locationData.locality else {
            print("Location Fetch Failed from app group storage:")
            return nil
        }
        
        guard let waqiResponse = repo.loadSavedHourlyAQI(),
              let waqiData = waqiResponse.data,
              let aqi = waqiData.aqi else {
            return nil
        }
        
        // Get date from WAQI response or use current date
        let date = waqiData.toDate() ?? Date()
        
        // Get location name from WAQI city name or use locality
        let locationName = waqiData.city?.name ?? locality
        
        // Convert WAQI AQI to app format
        let aqiColor = waqiData.toAQIColor()
        let aqiCategory = waqiData.toAQICategory()
        
        let config = WeatherAQIIntentIntent()
        config.WeatherWIdgetType = .aQI

        return WeatherAQIEntry(
            date: date,
            temperature: nil,
            locationName: locationName,
            weatherCondition: nil,
            weatherIcon: nil,
            aqi: Double(aqi),
            aqiColor: aqiColor,
            aqiCategory: aqiCategory,
            configuration: config
        )
    }
}

