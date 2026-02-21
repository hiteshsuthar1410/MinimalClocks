import Kingfisher
import SwiftUI
import WidgetKit

extension ContentView {

    // MARK: - Quick Actions Section
    var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(1...8, id: \.self) { _ in
                        PillButtonView()
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Productivity Section
    var productivitySection: some View {
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
    var dateAndTimeSection: some View {
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
    var motivationalQuoteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Motivational Quote")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)

            WidgetButtonView {
                MotivationalQuoteView(entry: MotivationalQuoteWidgetEntry(date: Date(), quote: QuoteModel.preview, unsplashPhoto: UnsplashPhoto.preview, image: motivationalQuoteWidgetBGImage, shouldUpdate: false))
            } action: {
                showWidgetInfo(.motivationalQuote)
            }
        }
    }

    // MARK: - Weather Section
    var weatherSection: some View {
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

    // MARK: - Profile Button
    @ViewBuilder
    var profileAvatar: some View {
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

    var profileToolbarButton: some View {
        Button {
            showSheet = .profile
        } label: {
            profileAvatar
        }
    }
}
