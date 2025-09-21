//
//  ContentView.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 11/01/25.
//

import SwiftUI
import Kingfisher
import WidgetKit
import FirebaseAuth
import Firebase

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    var columns = [
            GridItem(.flexible()), // First column
            GridItem(.flexible())  // Second column
        ]
    
    var column = [
            GridItem(.flexible()), // First column
        ]
    
    @State private var quotes = [Quote]()
    @State private var imageURL: URL?
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 24, height: 24)
                        //                        .clipShape(Circle())
                            .padding(.horizontal)
                            
                    }
                    .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image("avatar_placeholder")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .padding(.horizontal)
                    }
                }
//                           .shadow(radius: 10) // Optional shadow
                
                HStack {
                    Text("Hello,")
                        .foregroundStyle(.secondary)
                        .font(.custom("Outfit", size: 36))
                    
                    Text("Rohan")
                        .font(.custom("Outfit", size: 36))
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                
                ScrollView(.horizontal) { // Horizontal scrolling
                    LazyHStack(spacing: 16) {
                        ForEach(1...10, id: \.self) { index in
                            PillButtonView()
                                
                            }
//                            .frame(width: 80, height: 100)
//                            .background(Color.white)
//                            .cornerRadius(10)
//                            .shadow(radius: 5)
                        }
                    
                    .padding()
                }
                
                Text("Productivity")
                    .font(.custom("Outfit", size: 24))
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                
                VStack {
                    LazyVGrid(columns: columns) {
                        Button {
                        } label: {
                            ZStack {
                                Rectangle().fill(Color.gray.opacity(0.1))
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                
                                DayProgressCircleView(date: Date(), progressType: .completed)
                            }
                        }
                        
                        Button {
                        } label: {
                            ZStack {
                                Rectangle().fill(Color.gray.opacity(0.1))
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                
                                DayProgressCircleView(date: Date(), progressType: .remaining)
                            }
                        }
                        
                        //                    Button {
                        //                    } label: {
                        //                        ZStack {
                        //                            Rectangle().fill(Color.gray.opacity(0.1))
                        //                                .aspectRatio(contentMode: .fit)
                        //                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        //                            HStack {
                        //                                Text("More Options please!")
                        //                                Image(systemName: "chevron.right.circle")
                        //                            }
                        //                        }
                        //                    }
                    }
                    
                    
                    
                    
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.1))
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        
                        DayProgressBarView(date: Date(), progressType: .completed)
                    }
                    
                    
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.1))
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        
                        DayProgressBarView(date: Date(), progressType: .remaining)
                    }
                    
                    
                }
                .padding(.horizontal)
                    
    
                
                
                Text("Productivity (Medium)")
                    .font(.custom("Outfit", size: 24))
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                
                ZStack {
                    Rectangle().fill(Color.gray.opacity(0.1))
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    
                    MotivationalQuoteView(entry: MotivationalQuoteWidgetEntry.init(date: Date(), quote: QuoteModel.preview, unsplashPhoto: UnsplashPhoto.preview, image: nil))
                        
                }
                .padding(.horizontal)
            }
        }
        .task {
            do {
                // Basic random quote fetch
                //let quote = try await QuoteService.shared.fetchRandomQuote()
//                print("Random quote: \(quote.text) - \(quote.author)")
                QuoteService.shared.context = context
                let quotes = try QuoteService.shared.loadQuotesFromBundle()
                try QuoteService.shared.saveQuotesToDisk(from: quotes, context: context)
                let unsplash = try await UnsplashPhotoService.shared().fetchRandomPhoto(query: "Nature")
                print("Here we go \(unsplash.0)", unsplash.1)
//                let quote = try QuoteService.shared.fetchRandomUnshownQuote()
//                print("quote is \(quote.text)")
                
                
            } catch {
                print("Error: \(error)")
            }
            
//            do {
//                    // Fetch random photo and its metadata
//                let photo = try await UnsplashPhotoService.shared().fetchRandomPhoto(query: "nature")
//                    
//                    // Access image URL and metadata
//                if let urlString = photo.urls?.regular {
//                    if let url = URL(string: urlString) {
//                        self.imageURL = url
//                    }
//                }
//                    print("Image URL: \(photo.urls?.regular)")
//                    print("Photo ID: \(photo.id)")
//                    print("Description: \(photo.description ?? "No description")")
//                    print("Alt Description: \(photo.altDescription ?? "No alt description")")
//                    print("Photographer: \(photo.user?.name) (@\(photo.user?.username))")
//                    print("Created At: \(photo.createdAt)")
//                    
//                    // Use this data in your app as needed
//                } catch {
//                    print("Error fetching photo: \(error)")
//                }
            
                    QuoteService.shared.fetch(Quote.self, from: "PositiveQuotesDataset") { result in
                        
                            switch result {
                            case .success(let items):
                                // Create your timeline entries with the items
                                self.quotes = items
                                print(items)

            
                            case .failure(let error):
                                print("Error: \(error)")
                                // Handle error and create a fallback timeline
                                let entries = [MotivationalQuoteWidgetEntry(date: Date(), quote: QuoteModel.preview, unsplashPhoto: nil, image: nil)]
                            }
                        }
            if let user = Auth.auth().currentUser {
                user.getIDTokenResult { result, error in
                    if error != nil {
                        debugPrint(error, terminator: "\n\n")
                    }
                    debugPrint(result, terminator: "\n\n")
                }
            } else {
                debugPrint("\ncurrent user is nil")
            }

              // Send token to your backend via HTTPS
              // ...
            

//            let currentUser = FirebaseAuth.auth()?.currentUser
//            currentUser?.getIDToken(forcingRefresh: true) { idToken, error in
//                
//            }
//            currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
////              if let error = error {
////                // Handle error
////                  debugPrint(error)
////                return;
////              }
////                debugPrint(idToken)
//
//            }

        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                WidgetCenter.shared.reloadAllTimelines()
            default:
                break
            }
        }
    }
}
//@available(iOS 17.0, *)
//#Preview {
//    ContentView()
//}


struct PillButtonView: View {
    @State private var isSelected = false

    var body: some View {
        Button(action: {
            isSelected.toggle() // Toggle selection state
        }) {
            Text("Pill Button")
                .font(.custom("Outfit", size: 12))
                .fontWeight(.regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(height: 40)
                .background(isSelected ? Color.primary : Color.clear)
                .foregroundColor(isSelected ? Color.white : Color.primary)
                .clipShape(Capsule())
                .border(Color.pink)
                .overlay(
                    Capsule()
                        .stroke(Color.primary, lineWidth: 2)
                )
                .lineLimit(1)
            
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
//        .buttonStyle(BorderedProminentButtonStyle())
        .cornerRadius(24)
        .tint(Color.clear)
        
    }
}

struct PillButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PillButtonView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
