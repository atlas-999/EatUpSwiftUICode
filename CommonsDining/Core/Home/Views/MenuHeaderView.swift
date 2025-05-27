//
//  MenuHeaderView.swift
//  CommonsDining
//
//  Created by Caden Cooley on 2/16/25.
//

import SwiftUI

struct MenuHeaderView: View {
    
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Today's Menu")
                    .font(.title2)
                    .foregroundStyle(Color.theme.accent)
                    .fontWeight(.bold)
                Spacer()
                Text(homeViewModel.currentDay)
                    .font(.title2)
                    .foregroundStyle(Color.theme.accent)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 22)
            
            HStack {
                Picker("Select a period", selection: $homeViewModel.currentPeriod) {
                    ForEach(homeViewModel.getDailyPeriods().count > 0 ? homeViewModel.getDailyPeriods() : [.Breakfast, .Lunch, .Dinner], id: \.self) { period in
                        Text(period.rawValue.capitalized).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .preferredColorScheme(.light)
                
            }
            .padding(.bottom)
            .padding(.horizontal)
            
            HStack {
                Text("Menu Item".uppercased())
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.theme.secondaryTexasState)
                Spacer()
                Text("See it?".uppercased())
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.theme.secondaryTexasState)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.leading, 2)
        }
        .padding(.top)
        .background(
//            Color.theme.background // any non-transparent background
//                .shadow(color: Color.theme.secondaryText.opacity(0.2), radius: 10, x: 0, y: 0)
//                .mask(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 10, bottomLeading: 0, bottomTrailing: 0, topTrailing: 10)).padding(.top, -20))
            UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 20, bottomLeading: 0, bottomTrailing: 0, topTrailing: 20))
                .fill(Color.theme.background)
                .shadow(color: Color.theme.secondaryText.opacity(0.1), radius: 10, x: 0, y: -10)
                
                
        )
        
        

    }
}

#Preview {
    MenuHeaderView()
}
