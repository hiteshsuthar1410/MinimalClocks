import SwiftUI

extension ContentView {
    func loadMotivationalQuoteBackground() async {
        var storage = AppGroupStorage()
        let category = storage.loadBackgroundCategory()

        do {
            motivationalQuoteWidgetBGImage = try await UnsplashPhotoService.shared().fetchRandomPhoto(category: category).0
        } catch {
            print("Failed to load motivational quote background: \(error)")
        }
    }

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
