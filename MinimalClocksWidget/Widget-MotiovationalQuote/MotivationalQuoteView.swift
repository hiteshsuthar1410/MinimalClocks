//
//  DayProgressCircleView.swift
//  MinimalClocksWidgetExtension
//
//  Created by NovoTrax Dev1 on 11/01/25.
//

import Kingfisher
import SwiftUI
import WidgetKit

struct MotivationalQuoteView: View {
    var entry: MotivationalQuoteWidgetEntry
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if let imageURLString = entry.unsplashPhoto?.urls?.regular, !imageURLString.isEmpty {
                    if let imageURL = URL(string: imageURLString) {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .overlay {
                                    Color.clear
                                        .background(.black.opacity(0.3))
                                        .background(.thinMaterial.opacity(0.5).blendMode(.darken))
                                }
                            
                        } placeholder: {
                            ProgressView()
                        }
//                        .frame(width: 250, height: 250)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 141, maxHeight: 170)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
                
                Text(entry.quote.text)
                    .font(.custom("Outfit", size: 22))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
            }
        }
        .background {
            
        }
    }
}

@available(iOS 17.0, *)
struct WidgetViewPreviews: PreviewProvider {
  static var previews: some View {
    VStack {
        MotivationalQuoteView(entry: MotivationalQuoteWidgetEntry(date: Date(), quote: Quote.preview, unsplashPhoto: UnsplashPhoto.preview, image: nil))
            .containerBackground(.red.opacity(0), for: .widget)
    }
    .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
