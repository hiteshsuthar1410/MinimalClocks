//
//  WidgetExplanationSheet.swift
//  MinimalClocks
//
//  Created by Assistant on 25/01/25.
//

import SwiftUI

struct WidgetExplanationSheet: View {
    let widgetInfo: WidgetInfo
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Description Section
                    descriptionSection
                    
                    // Features Section
                    featuresSection
                    
                    // Benefits Section
                    benefitsSection
                    
                    // How to Use Section
                    howToUseSection
                    
                    // Add Widget Button
                    addWidgetButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Widget Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.body.weight(.medium))
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(widgetInfo.color.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: widgetInfo.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(widgetInfo.color)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0.0)
            
            // Title
            Text(widgetInfo.title)
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About This Widget")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            Text(widgetInfo.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Features")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(widgetInfo.features.enumerated()), id: \.offset) { index, feature in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.green)
                        
                        Text(feature)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .scaleEffect(isAnimating ? 1.0 : 0.95)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.1), value: isAnimating)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Benefits Section
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Benefits")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(widgetInfo.benefits.enumerated()), id: \.offset) { index, benefit in
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.orange)
                        
                        Text(benefit)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .scaleEffect(isAnimating ? 1.0 : 0.95)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.1 + 0.3), value: isAnimating)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - How to Use Section
    private var howToUseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Use")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                howToUseStep(
                    number: 1,
                    title: "Long Press",
                    description: "Long press on your home screen to enter jiggle mode"
                )
                
                howToUseStep(
                    number: 2,
                    title: "Add Widget",
                    description: "Tap the + button in the top-left corner"
                )
                
                howToUseStep(
                    number: 3,
                    title: "Search & Add",
                    description: "Search for 'Minimal Clocks' and select this widget"
                )
                
                howToUseStep(
                    number: 4,
                    title: "Enjoy",
                    description: "Your widget is now on your home screen!"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func howToUseStep(number: Int, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(widgetInfo.color)
                    .frame(width: 32, height: 32)
                
                Text("\(number)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(isAnimating ? 1.0 : 0.95)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.4).delay(Double(number) * 0.1 + 0.6), value: isAnimating)
    }
    
    // MARK: - Add Widget Button
    private var addWidgetButton: some View {
        Button(action: {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Open widget gallery
            if let url = URL(string: "App-prefs:APPLE_WIDGET") {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                
                Text("Add to Home Screen")
                    .font(.body.weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(widgetInfo.color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .scaleEffect(isAnimating ? 1.0 : 0.95)
        .opacity(isAnimating ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.4).delay(1.0), value: isAnimating)
    }
}

// MARK: - Preview
#Preview {
    WidgetExplanationSheet(widgetInfo: WidgetInfo.allWidgets[0])
}
