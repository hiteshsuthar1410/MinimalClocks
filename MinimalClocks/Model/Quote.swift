//
//  Quote.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 18/01/25.
//

import Foundation
import SwiftData

@Model
class QuoteModel {
    var id: String
    var text: String
    var author: String
    var source: String
    var isShown: Bool
    
    init(id: String, text: String, author: String, source: String, isShown: Bool = false) {
        self.id = id
        self.text = text
        self.author = author
        self.source = source
        self.isShown = isShown
    }
    
    convenience init(from quote: Quote) {
        self.init(
            id: quote.id,
            text: quote.text,
            author: quote.author,
            source: quote.source
        )
    }
    
    // MARK: - Preview Data
    static let preview: QuoteModel = QuoteModel(
        id: "PREVIEW001",
        text: "It's the possibility of having a dream come true that makes life interesting.",
        author: "Paulo Coelho",
        source: "The Alchemist",
        isShown: false
    )
    
    static let previews: [QuoteModel] = [
        QuoteModel(id: "PREVIEW001", text: "It's the possibility of having a dream come true that makes life interesting.", author: "Paulo Coelho", source: "The Alchemist"),
        QuoteModel(id: "PREVIEW002", text: "Not all those who wander are lost.", author: "J.R.R. Tolkien", source: "The Fellowship of the Ring"),
        QuoteModel(id: "PREVIEW003", text: "And may the odds be ever in your favor.", author: "Suzanne Collins", source: "The Hunger Games")
    ]
    
}

struct Quote: Codable {
    var id: String
    let text: String
    let author: String
    let source: String
    
    // MARK: - Preview Data
    static let preview: Quote = Quote(
        id: "PREVIEW001",
        text: "It's the possibility of having a dream come true that makes life interesting.",
        author: "Paulo Coelho",
        source: "The Alchemist"
    )
    
    static let previews: [Quote] = [
        Quote(id: "PREVIEW001", text: "It's the possibility of having a dream come true that makes life interesting.", author: "Paulo Coelho", source: "The Alchemist"),
        Quote(id: "PREVIEW002", text: "Not all those who wander are lost.", author: "J.R.R. Tolkien", source: "The Fellowship of the Ring"),
        Quote(id: "PREVIEW003", text: "And may the odds be ever in your favor.", author: "Suzanne Collins", source: "The Hunger Games")
    ]
}
