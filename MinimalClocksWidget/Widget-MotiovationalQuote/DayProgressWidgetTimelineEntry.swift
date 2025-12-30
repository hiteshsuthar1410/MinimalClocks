//
//  Protocols.swift
//  MinimalClocksWidgetExtension
//
//  Created by Hitesh Suthar on 19/01/25.
//

import SwiftUI
import WidgetKit

struct MotivationalQuoteWidgetEntry: TimelineEntry {
    let date: Date
    let quote: QuoteModel
    let unsplashPhoto: UnsplashPhoto?
    let image: UIImage?
    var shouldUpdate = true
}

struct DayProgressWidgetTimelineEntry: TimelineEntry, DayProgressViewProtocol {
    let date: Date
    let progressType: ProgressType
}
