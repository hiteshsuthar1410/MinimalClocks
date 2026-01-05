//
//  BackgroundCategorySelectionView.swift
//  MinimalClocks
//
//  Created on 01/01/25.
//

import Kingfisher
import SwiftUI
import WidgetKit

struct BackgroundCategorySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: BackgroundCategory
    @State private var isLoading = false
    @State private var categoryImageURLs: [BackgroundCategory: String] = [:]
    
    private var storage = AppGroupStorage()
    
    init() {
        let storage = AppGroupStorage()
        _selectedCategory = State(
            initialValue: self.storage.loadBackgroundCategory()
        )
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    ForEach(BackgroundCategory.allCases, id: \.self) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategory == category,
                            imageURL: categoryImageURLs[category],
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    selectCategory(category)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .navigationTitle("Choose Background")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Done") {
                            saveSelection()
                            dismiss()
                        }
                        .font(.body.weight(.semibold))
                    }
                }
            }
            .task {
                await loadSampleImages()
            }
        }
    }
    
    private func loadSampleImages() async {
        // Fetch actual sample images from Unsplash for each category
        // This ensures we get distinct, real images for each category
        for category in BackgroundCategory.allCases {
            if category == .random {
                // For random, use a default image
                categoryImageURLs[category] = category.sampleImageURL
                continue
            }
            
            // Fetch a real sample image for this category
            do {
                let (_, photo) = try await UnsplashPhotoService.shared().fetchRandomPhoto(query: category.unsplashQuery)
                if let regularURL = photo.urls?.regular {
                    categoryImageURLs[category] = regularURL
                } else {
                    // Fallback to predefined URL
                    categoryImageURLs[category] = category.sampleImageURL
                }
            } catch {
                // Fallback to predefined URL if fetch fails
                categoryImageURLs[category] = category.sampleImageURL
            }
        }
    }
    
    private func selectCategory(_ category: BackgroundCategory) {
        selectedCategory = category
    }
    
    private func saveSelection() {
        var storage = AppGroupStorage()
        storage.saveBackgroundCategory(selectedCategory)
        
        // Post notification to refresh widgets
        NotificationCenter.default.post(name: NSNotification.Name("BackgroundCategoryDidChange"), object: nil)
        
        // Reload widget timelines
        WidgetKit.WidgetCenter.shared.reloadTimelines(ofKind: "MotivationalQuoteWidget")
    }
}

struct CategoryCard: View {
    let category: BackgroundCategory
    let isSelected: Bool
    let imageURL: String?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Sample image - use fetched URL or fallback to category's sample URL
                KFImage(URL(string: imageURL ?? category.sampleImageURL))
                    .placeholder {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.gray.opacity(0.3),
                                        Color.gray.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay {
                                ProgressView()
                            }
                    }
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                
                // Category name
                HStack {
                    Text(category.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
            .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.1), radius: isSelected ? 8 : 4, y: 2)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BackgroundCategorySelectionView()
}

