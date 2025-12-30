//
//  Util.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 12/01/25.
//

import CoreLocation
import WidgetKit
import UIKit

struct Util {
    
    private init() {}
    
    static func createDayPercetageCompletionTimeline<T: TimelineEntry>(currentDate: Date,numberOfEntries: Int = 8, entryBuilder: (Date) -> T) -> Timeline<T> {
        var entries: [T] = []
        let blockDuration: TimeInterval = 864 // Each block is 864 seconds
        let _: TimeInterval = 86400 // Total seconds in a day
        
        // Calculate the remainder time left in the current block
        let secondsSinceMidnight = Calendar.current.dateComponents([.second], from: Calendar.current.startOfDay(for: currentDate), to: currentDate).second ?? 0
        let elapsedInCurrentBlock = TimeInterval(secondsSinceMidnight).truncatingRemainder(dividingBy: blockDuration)
        let remainingInCurrentBlock = blockDuration - elapsedInCurrentBlock
        
        // First entry: Complete the remaining time in the current block
        var nextDate = currentDate.addingTimeInterval(remainingInCurrentBlock)
        entries.append(entryBuilder(nextDate))
        
        // Generate subsequent entries, spaced 864 seconds apart
        for _ in 1..<numberOfEntries {
            nextDate = nextDate.addingTimeInterval(blockDuration)
            entries.append(entryBuilder(nextDate))
        }
        
        // Create the timeline
        return Timeline(entries: entries, policy: .atEnd)
    }

    static func calculateDayCompletionPercentages(for date: Date) -> (completed: Int, remaining: Int) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date) // Midnight of the current day
        let totalSecondsInDay: TimeInterval = 86400 // Total seconds in a day
        
        // Seconds elapsed since the start of the day
        let secondsElapsed = date.timeIntervalSince(startOfDay)
        
        // Percentage completed
        let completedPercentage = (secondsElapsed / totalSecondsInDay) * 100
        
        // Percentage remaining
        let remainingPercentage = 100 - Int(completedPercentage)
        
        return (completed: Int(completedPercentage), remaining: remainingPercentage)
    }
    
    static func progreessType(for config: ProgressTypeSelectionIntent) -> ProgressType {
        switch config.Progress {
        case .elapsed:
                return .completed
        case .remaining:
            return  .remaining
            
        default:
            return .completed
        }
    }
    
    static func handleOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let httpResponse = output.response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: output.data, encoding: .utf8) {
                print("❌ Server Error Response: \(errorString)")
            }
            throw URLError(.badServerResponse)
        }
        return output.data
    }
    
    static func getPlacemarkFrom(location: CLLocation?) async throws -> CLPlacemark {
        // Use the last reported location.
        guard let location else {
            throw WidgetDataError.locationNotFound
        }
        
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                throw WidgetDataError.placemarkNotFound
            }
            return placemark
        } catch {
            throw WidgetDataError.placemarkNotFound
        }
    }
    
    static func loadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("❌ Failed to load image from \(urlString): \(error)")
            return nil
        }
    }
}
