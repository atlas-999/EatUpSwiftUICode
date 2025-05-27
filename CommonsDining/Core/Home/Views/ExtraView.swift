//
//  RatingsView.swift
//  CommonsDining
//
//  Created by Caden Cooley on 2/5/25.
//

import SwiftUI

struct ExtraView: View {
    
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var extraViewModel: ExtraInfoViewModel
    
    var isTiny: Bool {
        return UIScreen.main.bounds.height < 700
    }
    
    var body: some View {
        ZStack {
            Image("InfoBack")
                .resizable()
            VStack {
                header
                    .padding(.top, isTiny ? 20 : 60)
                hoursSection
                    .padding(.horizontal)
                    .padding(.bottom)
                    .padding(.top, 10)
                ratingsSection
                    .background(
                        UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 20, bottomLeading: 0, bottomTrailing: 0, topTrailing: 20))
                            .fill(Color.theme.background)
                            .shadow(color: Color.theme.secondaryText.opacity(0.1), radius: 10, x: 0, y: -10))
                    .task {
                        print("task running")
                        extraViewModel.getWeeklyScores()
                        extraViewModel.getWeeklyHours()
                    }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    var hoursSection: some View {
        VStack {
            HStack {
                Text("This Week's Hours")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.theme.background)
                Spacer()
            }
            .padding(.bottom, 10)
            VStack(alignment: .leading, spacing: isTiny ? 5 : 15){
                if extraViewModel.weeklyHours.count > 0 {
                    ForEach(extraViewModel.weeklyHours, id: \.key) { key, value in
                        VStack(alignment:.leading) {
                            Text(key.uppercased())
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.theme.background.opacity(0.4))
                            Text(value)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.theme.background)
                        }
                    }
                }
                else if extraViewModel.weeklyHoursLoading == true {
                    ProgressView()
                        .foregroundColor(Color.theme.background)
                }
                else {
                    Text("No open hours found for this week.")
                        .font(.headline)
                        .fontWeight(.medium)
                        .padding(.top, 30)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var header: some View {
            VStack {
                HStack {
                    Spacer()
                    Text("Dining Info")
                        .font(.largeTitle)
                        .foregroundStyle(Color.theme.background)
                    Spacer()
                }
            }
    }
    
    var ratingsSection: some View {
        VStack(spacing: 0){
            HStack {
                Text("This Week's Ratings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.theme.accent)
                if isTiny {
                    Image(systemName: "chevron.up.chevron.down")
                        .rotationEffect(Angle(degrees: 90))
                        .foregroundColor(Color.theme.accent)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, isTiny ? 10 : 20)
            .padding(.bottom, 5)
            VStack {
                if extraViewModel.weeklyScores.count > 0 {
                    if isTiny {
                        ScrollView(.horizontal, showsIndicators: false, content: {
                            HStack(spacing: 30){
                                WeekRatingView(rating: !extraViewModel.weeklyScores.isEmpty ? extraViewModel.weeklyScores[0] : 0.0, weekDay: "Yesterday")
                                WeekRatingView(rating: !extraViewModel.weeklyScores.isEmpty ? extraViewModel.weeklyScores[1] : 0.0, weekDay: extraViewModel.pastdays[2])
                                WeekRatingView(rating: !extraViewModel.weeklyScores.isEmpty ? extraViewModel.weeklyScores[2] : 0.0, weekDay: extraViewModel.pastdays[3])
                                WeekRatingView(rating: !extraViewModel.weeklyScores.isEmpty ? extraViewModel.weeklyScores[3] : 0.0, weekDay: extraViewModel.pastdays[4])
                                WeekRatingView(rating: !extraViewModel.weeklyScores.isEmpty ? extraViewModel.weeklyScores[4] : 0.0, weekDay: extraViewModel.pastdays[5])
                                WeekRatingView(rating: !extraViewModel.weeklyScores.isEmpty ? extraViewModel.weeklyScores[5] : 0.0, weekDay: extraViewModel.pastdays[6])
                            }
                        })
                    }
                    else {
                        HStack {
                            WeekRatingView(rating: !extraViewModel.weeklyScores.isEmpty ? extraViewModel.weeklyScores[0] : 0.0, weekDay: "Yesterday")
                                .frame(maxWidth: UIScreen.main.bounds.width / 3)
                            Spacer()
                            WeekRatingView(rating: !extraViewModel.weeklyScores.isEmpty ? extraViewModel.weeklyScores[1] : 0.0, weekDay: extraViewModel.pastdays[2])
                                .frame(maxWidth: UIScreen.main.bounds.width / 3)
                            Spacer()
                            WeekRatingView(rating: !extraViewModel.weeklyScores.isEmpty ? extraViewModel.weeklyScores[2] : 0.0, weekDay: extraViewModel.pastdays[3])
                                .frame(maxWidth: UIScreen.main.bounds.width / 3)
                        }
                        
                        
                        HStack {
                            WeekRatingView(rating: !extraViewModel.weeklyScores.isEmpty ? extraViewModel.weeklyScores[3] : 0.0, weekDay: extraViewModel.pastdays[4])
                                .frame(maxWidth: UIScreen.main.bounds.width / 3)
                            Spacer()
                            WeekRatingView(rating: !extraViewModel.weeklyScores.isEmpty ? extraViewModel.weeklyScores[4] : 0.0, weekDay: extraViewModel.pastdays[5])
                                .frame(maxWidth: UIScreen.main.bounds.width / 3)
                            Spacer()
                            WeekRatingView(rating: !extraViewModel.weeklyScores.isEmpty ? extraViewModel.weeklyScores[5] : 0.0, weekDay: extraViewModel.pastdays[6])
                                .frame(maxWidth: UIScreen.main.bounds.width / 3)
                        }
                    }
                }
                else {
                    ProgressView()
                        .foregroundColor(Color.theme.red)
                }

            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            Spacer()
        }
    }
}

#Preview {
    ExtraView()
}
