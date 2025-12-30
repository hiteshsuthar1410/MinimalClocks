//
//  LocationSearchView.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 01/01/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct LocationSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var searchTask: Task<Void, Never>?
    
    let onLocationSelected: (CLLocation, String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar - Fixed position
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search for a city or location", text: $searchText)
                        .textFieldStyle(.plain)
                        .onChange(of: searchText) { oldValue, newValue in
                            // Cancel previous search task
                            searchTask?.cancel()
                            
                            // Debounce: wait 0.5 seconds after user stops typing
                            searchTask = Task {
                                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                                
                                // Check if task was cancelled
                                if Task.isCancelled { return }
                                
                                await MainActor.run {
                                    performSearch(query: newValue)
                                }
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchTask?.cancel()
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.top)
                .fixedSize(horizontal: false, vertical: true)
                
                // Search Results
                if isSearching {
                    ProgressView()
                        .padding()
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "location.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No results found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Try searching for a city name")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else if searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Search for a location")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Enter a city name or address to find locations")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(searchResults, id: \.self) { mapItem in
                                LocationResultRow(mapItem: mapItem) {
                                    selectLocation(mapItem: mapItem)
                                }
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                }
                Spacer()
            }
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        searchTask?.cancel()
                        dismiss()
                    }
                }
            }
            .onDisappear {
                searchTask?.cancel()
            }
        }
    }
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.address, .pointOfInterest]
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                isSearching = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    searchResults = []
                    return
                }
                
                guard let response = response else {
                    searchResults = []
                    return
                }
                
                // Get all results, prioritize cities but include others
                var cityResults: [MKMapItem] = []
                var otherResults: [MKMapItem] = []
                
                for item in response.mapItems {
                    if item.placemark.locality != nil {
                        cityResults.append(item)
                    } else {
                        otherResults.append(item)
                    }
                }
                
                // Combine: cities first, then other results
                searchResults = Array((cityResults + otherResults).prefix(15))
            }
        }
    }
    
    private func selectLocation(mapItem: MKMapItem) {
        let location = mapItem.placemark.location!
        
        // Get location name - prefer locality, then name, then formatted address
        var locationName = mapItem.placemark.locality ?? ""
        if locationName.isEmpty {
            locationName = mapItem.name ?? ""
        }
        if locationName.isEmpty {
            locationName = formatAddress(from: mapItem.placemark)
        }
        
        // Get locality for AQI API (city name)
        let locality = mapItem.placemark.locality ?? locationName
        
        onLocationSelected(location, locality)
        dismiss()
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let street = placemark.thoroughfare {
            components.append(street)
        }
        if let city = placemark.locality {
            components.append(city)
        }
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        if let country = placemark.country {
            components.append(country)
        }
        
        return components.joined(separator: ", ")
    }
}

struct LocationResultRow: View {
    let mapItem: MKMapItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(locationName)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if let address = formattedAddress {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var locationName: String {
        mapItem.placemark.locality ?? mapItem.name ?? "Unknown Location"
    }
    
    private var formattedAddress: String? {
        let placemark = mapItem.placemark
        var components: [String] = []
        
        if let city = placemark.locality {
            components.append(city)
        }
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        if let country = placemark.country {
            components.append(country)
        }
        
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}

