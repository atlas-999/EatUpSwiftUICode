//
//  FilterButton.swift
//  CommonsDining
//
//  Created by Caden Cooley on 4/4/25.
//

import SwiftUI

struct FilterButton: View {
    
    let text: String
    
    var body: some View {
        Text(text)
            .frame(height: 20)
            .padding(.horizontal)
            .background(
                Rectangle()
                    .fill(Color.theme.tertiaryText)
                    .frame(height: 40)
                    .cornerRadius(15)
            )
    }
}

#Preview {
    FilterButton(text: "Dinner")
}
