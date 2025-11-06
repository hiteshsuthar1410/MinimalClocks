//
//  WidgetExplanationSheetView.swift
//  MinimalClocks
//
//  Created by NovoTrax Dev1 on 02/11/25.
//

import SwiftUI

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
