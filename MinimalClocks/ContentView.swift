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
    @State private var motivationalQuoteWidgetBGImage: UIImage?
    @State private var selectedWidgetInfo: MCWidgetInfo?
    @State private var showingWidgetSheet = false
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    
                    // Header Section
                    headerSection
                    
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
                        // Profile action
                    } label: {
                        Image("avatar_placeholder")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .task {
            // Fetch and cache quotes from Firestore into SwiftData
            do {
                let serverQuotes = try await QuoteService.shared.fetch(Quote.self, from: "PositiveQuotesDataset")
                try QuoteService.shared.saveQuotesToDisk(from: serverQuotes, context: context)
            } catch {
                print("Error fetching/saving quotes: \(error)")
            }
            
            // Ensure we have some unshown quotes; refresh if low
            await QuoteService.shared.refreshQuotesIfNeeded(context: context, threshold: 5)
            
            // Fetch background image used in the in-app preview card
            do {
                motivationalQuoteWidgetBGImage = try await UnsplashPhotoService.shared().fetchRandomPhoto(query: "Nature").0
            } catch {
                // Ignore image errors in app preview path
            }
            
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
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .background:
                
                break
            case .active:
                Task { await QuoteService.shared.refreshQuotesIfNeeded(context: context, threshold: 5) }
            default:
                break
            }
        }
        .sheet(isPresented: $showingWidgetSheet) {
            if let widgetInfo = selectedWidgetInfo {
                WidgetExplanationSheetView(widgetInfo: widgetInfo)
            } else {
                Text("Info not avail")
            }
        }
        .onChange(of: showingWidgetSheet) { oldValue, newValue in
            if !newValue {
                // Reset selectedWidgetInfo when sheet is dismissed
                selectedWidgetInfo = nil
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Hello,")
                    .font(.title2.weight(.medium))
                    .foregroundColor(.secondary)
                
                Text("Rohan")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text("Track your day with beautiful widgets")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
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
        showingWidgetSheet = true
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
            isSelected.toggle()
        }) {
            Text("Quick Action")
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct PillButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PillButtonView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

// MARK: - Widget Explanation Sheet
struct WidgetExplanationSheetView: View {
    let widgetInfo: MCWidgetInfo
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddGuideSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(widgetInfo.color.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: widgetInfo.icon)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(widgetInfo.color)
                        }
                        
                        Text(widgetInfo.title)
                            .font(.largeTitle.weight(.bold))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About This Widget")
                            .font(.headline.weight(.semibold))
                        
                        Text(widgetInfo.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // How It Helps
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How It Helps")
                            .font(.headline.weight(.semibold))
                        
                        ForEach(widgetInfo.benefits, id: \.self) { benefit in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(benefit)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .sheet(isPresented: $showingAddGuideSheet) {
                WidgetAddGuideView()
            }
            .navigationTitle("Widget Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingAddGuideSheet = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            
        }
    }
}

// MARK: - Widget Add Guide View
struct WidgetAddGuideView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Add Widgets to Your Home Screen or Today View")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Group {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "hand.tap.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                            Text("**Touch and hold** an empty area on your Home Screen or Today View until the apps jiggle.")
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                            Text("Tap the **Edit** button in the upper-left corner.")
                        }
                        
                        if #available(iOS 26, *) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "widget.large.badge.plus")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                Text("Tap **Add Widget**.")
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                            Text("Use the **Search bar** to find the Minimal Clocks widgets.")
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "rectangle.3.offgrid.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                            Text("Select your preferred widget size and tap **Add Widget**.")
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                            Text("Drag the widget to your desired location, then tap **Done** or press the Home button.")
                        }
                    }
                    .font(.body)
                    .foregroundColor(.primary)
                    
                    Divider()
                    
                    Text("Enjoy your personalized widgets that help you stay focused, motivated, and productive throughout your day!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("How to Add Widgets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
