//
//  DateTimePickerProvider.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 01/11/25.
//


//
//  DateTimePickerWidget.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar
//

import WidgetKit
import SwiftUI

struct DateTimePickerProvider: TimelineProvider {
    func placeholder(in context: Context) -> DateTimePickerEntry {
        DateTimePickerEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DateTimePickerEntry) -> ()) {
        let entry = DateTimePickerEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DateTimePickerEntry>) -> Void) {
        let currentDate = Date()
        let entry = DateTimePickerEntry(date: currentDate)
        
        // Schedule next update at midnight (12:00 AM) today or tomorrow
        let calendar = Calendar.current
        let now = Date()
        let midnight = calendar.startOfDay(for: now)
        
        // If current time is past midnight today, schedule for tomorrow midnight
        // Otherwise, schedule for today midnight
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: midnight) ?? midnight
        
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        
        completion(timeline)
    }
}

struct DateTimePickerEntry: TimelineEntry {
    let date: Date
}

struct DateTimePickerWidgetEntryView: View {
    var entry: DateTimePickerProvider.Entry
    
    var body: some View {
        DateDayView(date: entry.date)
    }
}

struct DateTimePickerWidget: Widget {
    let kind: String = "DateTimePickerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DateTimePickerProvider()) { entry in
            if #available(iOS 17.0, *) {
                DateTimePickerWidgetEntryView(entry: entry)
                    .containerBackground(Color.clear, for: .widget)
            } else {
                DateTimePickerWidgetEntryView(entry: entry)
                    .containerBackground(Color.clear, for: .widget)
            }
        }
        .supportedFamilies([.systemMedium, .systemSmall])
        .configurationDisplayName("Date & Time")
        .description("A modern date and time display with real-time updates.")
        .contentMarginsDisabled()
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemMedium) {
    DateTimePickerWidget()
} timeline: {
    DateTimePickerEntry(date: Date())
    DateTimePickerEntry(date: Date().addingTimeInterval(60))
    DateTimePickerEntry(date: Date().addingTimeInterval(120))
}
