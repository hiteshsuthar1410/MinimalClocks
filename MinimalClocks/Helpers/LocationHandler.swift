//
//  LocationHandler.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 22/12/25.
//

import UIKit
import CoreLocation

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
