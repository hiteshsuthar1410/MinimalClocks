//
//  PillButtonView.swift
//  MinimalClocks
//
//  Created by Hitesh Suthar on 02/11/25.
//


import SwiftUI

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
