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
    
    enum ContentViewSheet: Identifiable {
        var id: Int { hashValue }
        
        case profile
        case widgetInfo
    }
    
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) var colorScheme
    
    @State private var quotes = [Quote]()
    @State private var imageURL: URL?
    @State private var motivationalQuoteWidgetBGImage: UIImage?
    @State private var selectedWidgetInfo: MCWidgetInfo?
    @State private var showSheet: ContentViewSheet? = nil
    
    private var columns = [
        GridItem(.flexible()), // First column
        GridItem(.flexible())  // Second column
    ]
    private var column = [
        GridItem(.flexible()), // First column
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    
                    // Date and Time Section
                    dateAndTimeSection
                    
                    
                    // Quick Actions Section
                    //                    quickActionsSection
                    
                    // Productivity Section
                    productivitySection
                    
                    // Motivational Quote Section
                    motivationalQuoteSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .navigationTitle("Minimal Clocks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSheet = .profile
                    } label: {
                        Group {
                            if let photoURLString = UserManager.shared.getUserPhotoURL(), let photoURL = URL(string: photoURLString) {
                                KFImage(photoURL)
                                    .placeholder {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFill()
                                    }
                                    .resizing(referenceSize: CGSize(width: 64, height: 64), mode: .aspectFill)
                                    .cacheMemoryOnly()
                                    .fade(duration: 0.25)
                                    .onFailure { error in
                                        print("Failed to load user profile image: \(error)")
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
            }
        }
        .task {
            authenticateUser()
            do { motivationalQuoteWidgetBGImage = try await UnsplashPhotoService.shared().fetchRandomPhoto(query: "Nature").0 } catch {}
            do {
                try await QuoteService.shared.refreshQuotesIfNeeded(context: context, threshold: 10)
            } catch {
                print("Quote refresh failed: \(error)")
            }
        }
        
        .sheet(item: $showSheet) { sheet in
            switch sheet {
            case .profile:
                ProfileView()
                    .presentationBackgroundInteraction(.disabled)
                    .presentationBackground(.regularMaterial)
                //                    .interactiveDismissDisabled()
                
                
            case .widgetInfo:
                if let widgetInfo = selectedWidgetInfo {
                    WidgetExplanationSheetView(widgetInfo: widgetInfo)
                } else {
                    Text("Info not avail")
                }
            }
        }
        
        .onChange(of: showSheet) { oldValue, newValue in
            if newValue != nil {
                // Reset selectedWidgetInfo when sheet is dismissed
                selectedWidgetInfo = nil
            }
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(1...8, id: \.self) { index in
                        PillButtonView()
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Productivity Section
    private var productivitySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Productivity")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            // Grid of widget buttons
            LazyVGrid(columns: columns, spacing: 16) {
                WidgetButtonView {
                    DayProgressCircleView(date: Date(), progressType: .completed)
                } action: {
                    showWidgetInfo(.dayProgressCircleCompleted)
                }
                
                WidgetButtonView {
                    DayProgressCircleView(date: Date(), progressType: .remaining)
                } action: {
                    showWidgetInfo(.dayProgressCircleRemaining)
                }
            }
            
            // Full-width progress bars
            VStack(spacing: 16) {
                WidgetButtonView {
                    DayProgressBarView(date: Date(), progressType: .completed)
                } action: {
                    showWidgetInfo(.dayProgressBarCompleted)
                }
                
                WidgetButtonView {
                    DayProgressBarView(date: Date(), progressType: .remaining)
                } action: {
                    showWidgetInfo(.dayProgressBarRemaining)
                }
            }
        }
    }
    // MARK: - Date and Time Section
    private var dateAndTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date and Time")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
                
                WidgetButtonView {
                    DateDayView()
                } action: {
                    showWidgetInfo(.dayDateMonth)
                }
        }
    }
    
    // MARK: - Motivational Quote Section
    private var motivationalQuoteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Motivational Quote")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            WidgetButtonView {
                MotivationalQuoteView(entry: MotivationalQuoteWidgetEntry.init(date: Date(), quote: QuoteModel.preview, unsplashPhoto: UnsplashPhoto.preview, image: motivationalQuoteWidgetBGImage, shouldUpdate: false))
            } action: {
                showWidgetInfo(.motivationalQuote)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func showWidgetInfo(_ widgetType: MCWidgetInfo.WidgetType) {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Set the selected widget info and show sheet
        selectedWidgetInfo = MCWidgetInfo.info(for: widgetType)
        print("DEBUG: Setting selectedWidgetInfo for \(widgetType) - \(selectedWidgetInfo?.title ?? "nil")")
        showSheet = .widgetInfo
    }
    
    private func authenticateUser() {
        if let user = Auth.auth().currentUser {
            user.getIDTokenResult { result, error in
                if error != nil {
                    debugPrint(error as Any, terminator: "\n")
                }
                debugPrint(result as Any, terminator: "\n")
            }
        } else {
            debugPrint("\ncurrent user is nil")
        }
    }
}
