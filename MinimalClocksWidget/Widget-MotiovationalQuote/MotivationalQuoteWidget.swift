//
//  MotivationalQuoteWidget.swift
//  MinimalClocksWidgetExtension
//
//  Created by Hitesh Suthar on 19/01/25.
//

import SwiftUI
import Kingfisher
import WidgetKit
@available(iOSApplicationExtension 17, *)
struct MotivationalQuoteWidgetProvider: TimelineProvider {
    
    typealias Entry = MotivationalQuoteWidgetEntry
    
    func placeholder(in context: Context) -> MotivationalQuoteWidgetEntry {
        MotivationalQuoteWidgetEntry(date: Date(), quote: Quote.preview, unsplashPhoto: UnsplashPhoto.preview, image: Image(systemName: "photo"))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MotivationalQuoteWidgetEntry) -> Void) {
        let entry = MotivationalQuoteWidgetEntry(date: Date(), quote: Quote.preview, unsplashPhoto: UnsplashPhoto.preview, image: Image(systemName: "photo"))
        completion(entry)
    }
    
    
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<MotivationalQuoteWidgetEntry>) -> Void) {
//        Task {
//            do {/Users/novotraxdev1/Documents/Hitesh Suthar/quotes.json
//                let quote = try await QuoteService.shared.fetchRandomQuote()
//                let entry = MotivationalQuoteWidgetEntry(date: .now, quote: quote, unsplashPhoto: nil, image: nil)
//                let timeline = Timeline(entries: [entry], policy: .after(Date.tomorrowMidnight))
//                completion(timeline)
//            } catch {
//                let entry = MotivationalQuoteWidgetEntry(date: .now, quote: Quote.preview, unsplashPhoto: nil, image: nil)
//                let timeline = Timeline(entries: [entry], policy: .after(Date.tomorrowMidnight))
//                completion(timeline)
//            }
//        }
            let url = URL(string: "http://numbersapi.com/random/trivia")!
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data {
                    let respose = String(decoding: data, as: UTF8.self)
                    let entry = MotivationalQuoteWidgetEntry(date: .now, quote: Quote(id: "autg", text: respose, author: "sdsd", source: ""), unsplashPhoto: nil, image: nil)
                    let nextRefresh = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
                    let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
                    completion(timeline)
                } else {
                    let entry = MotivationalQuoteWidgetEntry(date: .now, quote: Quote(id: "autg", text: error?.localizedDescription ?? "Kuch error", author: "sdsd", source: ""), unsplashPhoto: nil, image: nil)
                    let timeline = Timeline(entries: [entry], policy: .after(Date.tomorrowMidnight))
                    completion(timeline)
                }
            }
        .resume()
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
                    .containerBackground(Color.gray.opacity(0.2), for: .widget)
            } else {
                MotivationalQuoteView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Motivational Quote")
        .description("An inpirational quote with a beautiful backdrop.")
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    MotivationalQuoteWidget()
} timeline: {
    MotivationalQuoteWidgetEntry(date: Date(), quote: Quote.preview, unsplashPhoto: UnsplashPhoto.preview, image: nil)
}
