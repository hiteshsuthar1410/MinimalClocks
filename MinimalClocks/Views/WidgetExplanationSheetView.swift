//
//  WidgetExplanationSheetView.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 02/11/25.
//

import SwiftUI
import CoreLocation
import WidgetKit

struct WidgetExplanationSheetView: View {
    let widgetInfo: MCWidgetInfo
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddGuideSheet = false
    @State private var showingLocationSearch = false
    @State private var currentLocation: String = "Loading..."
    @State private var isRefreshing = false
    
    private var isWeatherWidget: Bool {
        widgetInfo.widgetType == .weatherTemperature || widgetInfo.widgetType == .weatherAQI
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(widgetInfo.color.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: widgetInfo.icon)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(widgetInfo.color)
                        }
                        
                        Text(widgetInfo.title)
                            .font(.largeTitle.weight(.bold))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Location Section (for weather widgets only)
                    if isWeatherWidget {
                        locationSection
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About This Widget")
                            .font(.headline.weight(.semibold))
                        
                        Text(widgetInfo.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // How It Helps
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How It Helps")
                            .font(.headline.weight(.semibold))
                        
                        ForEach(widgetInfo.benefits, id: \.self) { benefit in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(benefit)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .sheet(isPresented: $showingAddGuideSheet) {
                WidgetAddGuideView()
            }
            .sheet(isPresented: $showingLocationSearch) {
                LocationSearchView { location, locality in
                    handleLocationSelected(location: location, locality: locality)
                }
            }
            .navigationTitle("Widget Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingAddGuideSheet = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .onAppear {
                if isWeatherWidget {
                    loadCurrentLocation()
                }
            }
        }
    }
    
    // MARK: - Location Section
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline.weight(.semibold))
            
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .foregroundColor(widgetInfo.color)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(currentLocation)
                        .font(.body.weight(.medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: {
                    showingLocationSearch = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                        Text("Change")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(widgetInfo.color)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if isRefreshing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Updating weather data...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Helper Methods
    private func loadCurrentLocation() {
        let storage = AppGroupStorage()
        let locationData = storage.loadLocationFromSharedDefaults()
        currentLocation = locationData.locality ?? "Unknown Location"
    }
    
    private func handleLocationSelected(location: CLLocation, locality: String) {
        isRefreshing = true
        
        // Save location to shared defaults
        var storage = AppGroupStorage()
        storage.saveLocationToSharedDefaults(location: location, city: locality)
        
        // Update current location display
        currentLocation = locality
        
        // Refresh weather and AQI data
        Task {
            await refreshWeatherData(location: location, locality: locality)
            
            DispatchQueue.main.async {
                isRefreshing = false
                
                // Post notification to update ContentView previews
                NotificationCenter.default.post(name: NSNotification.Name("LocationDidChange"), object: nil)
                
                // Reload widgets - use specific widget kind for better performance
                WidgetCenter.shared.reloadTimelines(ofKind: "WeatherAQIWidget")
            }
        }
    }
    
    private func refreshWeatherData(location: CLLocation, locality: String) async {
        let repo = WeatherAQIRepository()
        
        // Fetch and save both weather and AQI data
        _ = await repo.fetchAndSaveLatestHourlyWeather(for: location, locality: locality)
        _ = await repo.fetchAndSaveLatestHourlyAQI(for: location, locality: locality)
    }
}
