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
                
                // Timeline with refresh after 2 hours
                let nextRefresh = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
                
                completion(timeline)
            } catch {
                print("Error in getTimeline: \(error)")
                // Fallback entry with preview quote
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

// MARK: - Demo Entry Functions
extension MotivationalQuoteWidget {
    
    // Static demo entries for app display
    static let demoQuoteEntries: [MotivationalQuoteWidgetEntry] = [
        MotivationalQuoteWidgetEntry(
            date: Date(),
            quote: QuoteModel(
                id: "DEMO001",
                text: "The only way to do great work is to love what you do.",
                author: "Steve Jobs",
                source: "Stanford Commencement Speech",
                isShown: false
            ),
            unsplashPhoto: UnsplashPhoto.preview,
            image: UIImage(named: "backupGradi")
        ),
        MotivationalQuoteWidgetEntry(
            date: Date(),
            quote: QuoteModel(
                id: "DEMO002",
                text: "Innovation distinguishes between a leader and a follower.",
                author: "Steve Jobs",
                source: "Business Philosophy",
                isShown: false
            ),
            unsplashPhoto: UnsplashPhoto.preview,
            image: UIImage(named: "backupGradi")
        ),
        MotivationalQuoteWidgetEntry(
            date: Date(),
            quote: QuoteModel(
                id: "DEMO003",
                text: "Life is what happens to you while you're busy making other plans.",
                author: "John Lennon",
                source: "Beautiful Boy",
                isShown: false
            ),
            unsplashPhoto: UnsplashPhoto.preview,
            image: UIImage(named: "backupGradi")
        ),
        MotivationalQuoteWidgetEntry(
            date: Date(),
            quote: QuoteModel(
                id: "DEMO004",
                text: "The future belongs to those who believe in the beauty of their dreams.",
                author: "Eleanor Roosevelt",
                source: "Inspirational Quote",
                isShown: false
            ),
            unsplashPhoto: UnsplashPhoto.preview,
            image: UIImage(named: "backupGradi")
        ),
        MotivationalQuoteWidgetEntry(
            date: Date(),
            quote: QuoteModel(
                id: "DEMO005",
                text: "Success is not final, failure is not fatal: it is the courage to continue that counts.",
                author: "Winston Churchill",
                source: "Leadership Philosophy",
                isShown: false
            ),
            unsplashPhoto: UnsplashPhoto.preview,
            image: UIImage(named: "backupGradi")
        )
    ]
    
    // Get a random demo entry
    static func getRandomDemoEntry() -> MotivationalQuoteWidgetEntry {
        return demoQuoteEntries.randomElement() ?? demoQuoteEntries[0]
    }
    
    // Get a specific demo entry by index
    static func getDemoEntry(at index: Int) -> MotivationalQuoteWidgetEntry {
        let safeIndex = max(0, min(index, demoQuoteEntries.count - 1))
        return demoQuoteEntries[safeIndex]
    }
    
    // Create async demo entry with real image data
    static func createAsyncDemoEntry() async -> MotivationalQuoteWidgetEntry {
        do {
            // Try to fetch real image data
            let imageData = try await UnsplashPhotoService.shared().fetchRandomPhoto(query: "Nature")
            
            // Use a random demo quote
            let randomQuote = demoQuoteEntries.randomElement()?.quote ?? QuoteModel.preview
            
            return MotivationalQuoteWidgetEntry(
                date: Date(),
                quote: randomQuote,
                unsplashPhoto: imageData.1,
                image: imageData.0
            )
        } catch {
            print("Error fetching real data for demo: \(error)")
            // Fallback to static demo entry
            return getRandomDemoEntry()
        }
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemLarge) {
    MotivationalQuoteWidget()
} timeline: {
    MotivationalQuoteWidgetEntry(date: Date(), quote: QuoteModel.preview, unsplashPhoto: UnsplashPhoto.preview, image: UIImage(named: "backupGradi"))
}



