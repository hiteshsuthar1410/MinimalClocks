//
//  WeatherAQIWidgetView.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 07/11/25.
//
import SwiftUI

struct WeatherAQIWidgetView: View {
    var entry: WeatherAQIProvider.Entry
    
    @Environment(\.colorScheme) var colorScheme
    
    private var gradientColors: (start: Color, end: Color) {
        // If AQI mode, use AQI color
        if entry.isAQIMode, let aqiColor = entry.aqiColor {
            let backgroundColor = colorScheme == .dark ? Color.black : Color.white
            return (backgroundColor, aqiColor.swiftUIColor)
        }
        
        // Otherwise use weather condition gradient
        if let condition = entry.weatherCondition {
            return condition.conditionType.gradientColors(for: colorScheme)
        }
        // Default gradient for unknown
        return colorScheme == .dark
            ? (Color.black, Color(white: 0.3))
            : (Color.white, Color(white: 0.85))
    }
    
    // AQI milestones: 0-50 (Good), 51-100 (Moderate), 101-150 (Unhealthy for Sensitive), 151-200 (Unhealthy), 201-300 (Very Unhealthy), 301+ (Hazardous)
    private var aqiMilestones: [(value: Int, label: String)] {
        [(0, "0"), (50, "50"), (100, "100"), (150, "150"), (200, "200"), (300, "300"), (500, "500")]
    }
    
    private func aqiPosition(for aqi: Int, in width: CGFloat) -> CGFloat {
        // AQI scale: 0-500, but most common is 0-300
        let maxAQI: CGFloat = 300
        let clampedAQI = min(CGFloat(aqi), maxAQI)
        return (clampedAQI / maxAQI) * width
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with smooth blending gradient
                let backgroundColor = colorScheme == .dark ? Color.black : Color.white
                let gradientHeight = geometry.size.height * 0.5 // Increased to 50%
                
                // Base background
                backgroundColor
                
                // Smooth gradient that blends from transparent to full color
                VStack(spacing: 0) {
                    Spacer()
                    
                    LinearGradient(
                        stops: [
                            .init(color: backgroundColor.opacity(0), location: 0.0),
                            .init(color: gradientColors.end.opacity(0.2), location: 0.3),
                            .init(color: gradientColors.end.opacity(0.6), location: 0.7),
                            .init(color: gradientColors.end, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: gradientHeight)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 0) {
                    if entry.isAQIMode {
                        // AQI Display
                        if let aqi = entry.aqi {
                            // AQI Value
                            Text(aqi, format: .number)
                                .font(.custom("Outfit", size: 30))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            // Location name
                            Text(entry.locationName ?? "Location Error")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.custom("Outfit", size: 14))
                                .padding(.horizontal)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                            
                            Spacer()
                            
                            // AQI Category
                            if let category = entry.aqiCategory {
                                Text(category)
                                    .font(.caption)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .lineLimit(1)
                                    .padding(.leading)
                                    .padding(.trailing, 4)
                            }
                            
                            // AQI Meter
                            AQIMeterView(aqi: aqi, aqiColor: entry.aqiColor?.swiftUIColor ?? .gray)
                                .padding(.horizontal)
                            
                        } else {
                            Text("Loading...")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    } else {
                        // Temperature Display
                        if let temp = entry.temperature {
                            HStack(alignment: .bottom, spacing: 0) {
                                Text("\(Int(temp))°")
                                    .font(.custom("Outfit", size: 50))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .padding(.horizontal)
                                    .padding(.top)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Location name
                            Text(entry.locationName ?? "Location Error")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.custom("Outfit", size: 20))
                                .padding(.horizontal)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            // Weather condition icon and type
                            HStack(spacing: 8) {
                                // SF Symbol based on weather condition type (time-aware)
                                if let condition = entry.weatherCondition {
                                    Image(systemName: condition.conditionType.sfSymbolName(for: entry.date))
                                        .font(.title2)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                                
                                // Weather condition description
                                if let condition = entry.weatherCondition {
                                    Text(condition.description.text)
                                        .font(.caption)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .lineLimit(1)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .padding(.trailing, 4)
                            
                        } else {
                            Text("Loading...")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }
}

// MARK: - AQI Meter View
struct AQIMeterView: View {
    let aqi: Double
    let aqiColor: Color
    
    // AQI milestones: 0, 50, 100, 150, 200, 300
    private let milestones: [Int] = [0, 50, 100, 150, 200, 300]
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let maxAQI: CGFloat = 300
            let clampedAQI = min(CGFloat(aqi), maxAQI)
            let position = (clampedAQI / maxAQI) * width
            
            VStack(spacing: 4) {
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    // Filled portion
                    RoundedRectangle(cornerRadius: 2)
                        .fill(aqiColor)
                        .frame(width: position, height: 4)
                    
                    // Milestone markers
                    ForEach(milestones, id: \.self) { milestone in
                        let milestonePosition = (CGFloat(milestone) / maxAQI) * width
                        
                        Circle()
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: 3, height: 3)
                            .offset(x: milestonePosition - 1.5)
                    }
                    
                    // Current AQI indicator
                    Circle()
                        .fill(aqiColor)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 2))
                        .offset(x: position - 4)
                }
            }
        }
        .frame(height: 10)
    }
}
