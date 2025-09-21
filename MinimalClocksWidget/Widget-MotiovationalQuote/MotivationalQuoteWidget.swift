//
//  MotivationalQuoteWidget.swift
//  MinimalClocksWidgetExtension
//
//  Created by Hitesh Suthar on 19/01/25.
//

import SwiftUI
import Kingfisher
import WidgetKit
import SwiftData

@available(iOSApplicationExtension 17, *)
struct MotivationalQuoteWidgetProvider: TimelineProvider {

    typealias Entry = MotivationalQuoteWidgetEntry
    
    func placeholder(in context: Context) -> MotivationalQuoteWidgetEntry {
        MotivationalQuoteWidgetEntry(date: Date(), quote: QuoteModel.preview, unsplashPhoto: UnsplashPhoto.preview, image: UIImage(named: "backupGradi"))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MotivationalQuoteWidgetEntry) -> Void) {
        let entry = MotivationalQuoteWidgetEntry(date: Date(), quote: QuoteModel.preview, unsplashPhoto: UnsplashPhoto.preview, image: UIImage(named: "backupGradi"))
        completion(entry)
    }
    
    
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MotivationalQuoteWidgetEntry>) -> Void) {
        Task {
            do {
                
                // Fetch relevant image
                let imageData = try await UnsplashPhotoService.shared().fetchRandomPhoto(query: "Nature")
                
                // Build entry
                let entry = MotivationalQuoteWidgetEntry(date: Date(), quote: QuoteModel.preview, unsplashPhoto: imageData.1, image: imageData.0)
                
                // Timeline with refresh after 1 hour
                let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
                
                completion(timeline)
            } catch {
                // Fallback entry
                let entry = MotivationalQuoteWidgetEntry(date: Date(), quote: QuoteModel.preview, unsplashPhoto: UnsplashPhoto(id: "", description: "", altDescription: "", urls: Urls(regular: ""), user: UnsplashUser(name: "", username: ""), createdAt: ""), image: UIImage(named: "backupGradi")!)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
                
            }
        }
        
    }
}


struct MotivationalQuoteWidgetTimelineEntryView : View {
    var entry: MotivationalQuoteWidgetProvider.Entry
    var body: some View {
        MotivationalQuoteView(entry: entry)
    }
}


struct MotivationalQuoteWidget: Widget {
    
    static let kind: String = "MotivationalQuoteWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: MotivationalQuoteWidget.kind, provider: MotivationalQuoteWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                MotivationalQuoteView(entry: entry)
                    .modelContainer(for: [QuoteModel.self])
                    .containerBackground(.clear, for: .widget)
                    
            } else {
                MotivationalQuoteView(entry: entry)
                    .modelContainer(for: [QuoteModel.self])
                    .containerBackground(.clear, for: .widget)
            }
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Motivational Quote")
        .description("An inpirational quote with a beautiful backdrop.")
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemLarge) {
    MotivationalQuoteWidget()
} timeline: {
    MotivationalQuoteWidgetEntry(date: Date(), quote: QuoteModel.preview, unsplashPhoto: UnsplashPhoto.preview, image: UIImage(named: "backupGradi"))
}



