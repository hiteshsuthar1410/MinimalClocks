//
//  AppGroupStorage.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 12/11/25.
//

import Foundation
import CoreLocation.CLLocation

struct AppGroupStorage {
    private let appGroupID = "group.in.hiteshsuthar.MinimalClocks"
    lazy private var sharedDefaults = UserDefaults(suiteName: appGroupID)!
    
    mutating func saveLocationToSharedDefaults(location: CLLocation, city:
                                      String?) {
        let data: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "city": city ?? ""
        ]
        sharedDefaults.set(data, forKey: "savedLocation")
        sharedDefaults.synchronize()
    }
    
    func loadLocationFromSharedDefaults() -> (location: CLLocation?, locality: String?) {
        let sharedDefaults = UserDefaults(suiteName: appGroupID)!
        
        guard let data = sharedDefaults.dictionary(forKey: "savedLocation"),
              let lat = data["latitude"] as? Double,
              let lon = data["longitude"] as? Double else {
            return (nil, nil)
        }
        
        let location = CLLocation(latitude: lat, longitude: lon)
        let city = data["city"] as? String
        return (location, city)
    }

        func save<T: Codable>(_ data: T, forKey key: String) throws {
            let containerURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
            let url = containerURL.appendingPathComponent("\(key).json")
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: url)
        }

        func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T {
            let containerURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
            let url = containerURL.appendingPathComponent("\(key).json")
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(type, from: data)
        }
}
