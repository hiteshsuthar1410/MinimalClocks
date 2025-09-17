//
//  Protocols.swift
//  MinimalClocksWidgetExtension
//
//  Created by NovoTrax Dev1 on 19/01/25.
//

import SwiftUI
import WidgetKit

struct MotivationalQuoteWidgetEntry: TimelineEntry {
    let date: Date
    let quote: Quote
    let unsplashPhoto: UnsplashPhoto?
    let image: Image?
}

struct DayProgressWidgetTimelineEntry: TimelineEntry, DayProgressViewProtocol {
    let date: Date
    let progressType: ProgressType
}
