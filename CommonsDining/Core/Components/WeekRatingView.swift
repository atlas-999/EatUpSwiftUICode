//
//  WeekRatingView.swift
//  CommonsDining
//
//  Created by Caden Cooley on 4/27/25.
//

import SwiftUI

struct WeekRatingView: View {
    
    let rating: Float
    let weekDay: String
    
    var localRating: CGFloat {
        return CGFloat(rating > 0.99 ? ((rating * 100) - 1) : rating * 100)
    }
    
    var body: some View {
        VStack (spacing: 0){
            RatingGraphic2(size: 65, strokewidth: 6, rating: localRating/100)
                .frame(maxHeight: 100)
                .overlay (
                    Text(String(format: "%.0f", localRating))
                        .font(.title)
                        .foregroundColor(Color.theme.accent)
                        .fontWeight(.medium)
                )
            Text(weekDay)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(Color.theme.secondaryText)

        }
    }
}

#Preview {
    WeekRatingView(rating: 0.55, weekDay: "Tuesday")
}
