//
//  RateButton.swift
//  CommonsDining
//
//  Created by Caden Cooley on 4/15/25.
//

import SwiftUI

struct RateButton: View {
    
    let isSelected: Bool
    let ratingText: String
    
    var body: some View {
        ZStack {
            if isSelected {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.theme.blue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.theme.blue, lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.theme.background)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Text(ratingText)
                .foregroundStyle(isSelected ? Color.theme.background : Color.theme.blue.opacity(0.7))
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .clipShape(RoundedRectangle(cornerRadius: 5)) // ensures consistent border clipping
    }
}

#Preview {
    RateButton(isSelected: false, ratingText: "Busy")
}
