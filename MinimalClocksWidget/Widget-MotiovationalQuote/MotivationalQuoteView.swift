//
//  DayProgressCircleView.swift
//  MinimalClocksWidgetExtension
//
//  Created by NovoTrax Dev1 on 11/01/25.
//

import Kingfisher
import SwiftData
import SwiftUI
import WidgetKit

struct MotivationalQuoteView: View {
    var entry: MotivationalQuoteWidgetEntry
    @Query var quotes: [QuoteModel]
    @Environment(\.modelContext) private var context
    
    var body: some View {

        ZStack {
            Image(uiImage: entry.image ?? UIImage(named: "backupGradi")!)
                .resizable()
                .scaledToFill()
            
            Text(entry.quote.text)
                .font(.custom("Outfit", size: 22))
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .background(Color.black.opacity(0.7))
                .environment(\.colorScheme, .dark)
                
        }
        .frame(width: 380)
        .edgesIgnoringSafeArea(.all)
    }
}

@available(iOS 17.0, *)
struct WidgetViewPreviews: PreviewProvider {
  static var previews: some View {
    VStack {
        MotivationalQuoteView(entry: MotivationalQuoteWidgetEntry(date: Date(), quote: QuoteModel.preview, unsplashPhoto: UnsplashPhoto.preview, image: nil))
            .containerBackground(.red.opacity(0), for: .widget)
    }
    .previewContext(WidgetPreviewContext(family: .systemLarge))
  }
}
