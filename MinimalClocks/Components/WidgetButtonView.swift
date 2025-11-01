//
//  WidgetButtonView.swift
//  MinimalClocks
//
//  Created by NovoTrax Dev1 on 21/09/25.
//

import SwiftUI

// MARK: - Widget Button View
struct WidgetButtonView<Content: View>: View {
    let content: Content
    let action: () -> Void
    
    init(@ViewBuilder content: () -> Content, action: @escaping () -> Void) {
        self.content = content()
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background with widget-like styling
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(maxWidth: .infinity)
                    .frame(height: 160) // Standard iPhone widget height
                
                // Content overlay
                content
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
//        .buttonStyle(WidgetButtonStyle())
    }
}

// MARK: - Custom Button Style
struct WidgetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onTapGesture {
                // Add subtle haptic feedback on tap
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
    }
}

