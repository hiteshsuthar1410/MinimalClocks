//
//  WidgetAddGuideView.swift
//  MinimalClocks
//
//  Created by NovoTrax Dev1 on 02/11/25.
//

import SwiftUI

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
