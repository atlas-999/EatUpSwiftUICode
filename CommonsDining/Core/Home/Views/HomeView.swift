//
//  HomeView.swift
//  CommonsDining
//
//  Created by Caden Cooley on 2/2/25.
//

import SwiftUI

// Need to animate top and section header like instagram

struct HomeView: View {
    
    @Binding var showRatingPopUp: Bool
    var isTiny: Bool {
        return UIScreen.main.bounds.height < 700
    }
    var timeFromRate: Double {
        return Date().timeIntervalSince1970 - homeViewModel.lastRated
    }
    
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var menuViewModel: MenuPageViewModel
    @EnvironmentObject private var extraViewModel: ExtraInfoViewModel
    @State private var offset = CGFloat.zero
    
    var body: some View {
        ZStack {
            Image("Launch")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: UIScreen.main.bounds.width)
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white)
                    .frame(height: offset + 350 >= 0  ? offset + 350 > 300 ? 350 : offset + 350 : 0)
            }
            VStack(spacing: 0){
                ScrollView(showsIndicators: false){
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]){
                        
                        header
                            .padding(.top, isTiny ? 20 : 60)
                            .padding(.bottom, homeViewModel.openStatusString.contains("Closed") ? 100 : 20)
                            .task {
                                homeViewModel.getOpenStatusString()
                                homeViewModel.getTodaysRatings()
                            }
                        if !homeViewModel.openStatusString.contains("Closed") {
                            ratingSection
                                .padding(.top, 5)
                        }
                        MenuHeaderView()
                        VStack {
                            TodaysMenuView()
                                .zIndex(1)
                        }
                        .frame(minHeight: UIScreen.main.bounds.height/2)
                        .background(GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.y)
                        })
                        .onPreferenceChange(ViewOffsetKey.self) { newValue in
                            if abs(offset - newValue) > 1 { // threshold to reduce unnecessary updates
                                DispatchQueue.main.async {
                                    offset = newValue
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
                .refreshable {
                    do {
                        homeViewModel.getOpenStatusString()
                        try await homeViewModel.getTodaysRatingsAsync()
                    }
                    catch {
                        print("Error")
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    var header: some View {
        HStack {
            Spacer()
            VStack {
                HStack {
                    Text("Commons Dining")
                        .font(.largeTitle)
                        .foregroundStyle(Color.theme.background)
                    Image(systemName: "chevron.down")
                        .font(.title3)
                        .foregroundColor(Color.theme.background.opacity(0.7))
                }
                Text(homeViewModel.openStatusString)
                    .foregroundStyle(Color(Color.theme.background.opacity(0.7)))
                    
            }
            Spacer()
        }
    }
    
    var ratingSection: some View {
        VStack (spacing: 0){
            ZStack {
                RatingGraphic(size: isTiny ? UIScreen.main.bounds.height/4 : 190, strokewidth: 10, rating: homeViewModel.openStatusString.contains("Closed") || homeViewModel.numRatings == 0 ? 0.0 : CGFloat(homeViewModel.diningScore))
                    .frame(maxHeight: UIScreen.main.bounds.height/3)

                Circle()
                    .frame(width: 200-20*2)
                    .foregroundColor(Color.clear)
                    .overlay(content: {
                        VStack(spacing: 0){
                            Text(homeViewModel.openStatusString.contains("Closed") || homeViewModel.numRatings == 0 ? "0" : homeViewModel.diningScore > 0.99 ? "\(Int(homeViewModel.diningScore * 100) - 1)" : "\(Int(homeViewModel.diningScore * 100))")
                                .font(.system(size: 200/2.7))
                                .fontWeight(.bold)
                                .animation(.easeInOut(duration: 0.5), value: homeViewModel.diningScore)
                                .foregroundColor(Color.theme.background)
                                .padding(.top)
                            Text("Dining Score")
                                .font(isTiny ? .title3 : .title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.theme.background)
                            Text(timeFromRate >= 1800 ? "Tap to Rate" : "Rate in \(Int(30-timeFromRate/60))m")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.theme.background.opacity(0.5))
                                .padding(.bottom, 20)
                        }
                        
                    })
                    .onTapGesture {
                        if !homeViewModel.openStatusString.contains("Closed") && timeFromRate >= 1800 {
                            showRatingPopUp.toggle()
                        }
                    }
            }
            .padding(.bottom, 30)
            HStack {
                Spacer()
                VStack(spacing: 0){
                    RatingGraphic(size: isTiny ? 50 : 65, strokewidth: 5, rating: homeViewModel.openStatusString.contains("Closed") || homeViewModel.numRatings == 0 ? 0.0 : CGFloat(homeViewModel.crowdScore))
                        .frame(maxHeight: UIScreen.main.bounds.height/10)
                        .overlay(content: {
                            Text(homeViewModel.openStatusString.contains("Closed") || homeViewModel.numRatings == 0 ? "0" : homeViewModel.crowdScore > 0.99 ? "\(Int(homeViewModel.crowdScore * 100) - 1)" : "\(Int(homeViewModel.crowdScore * 100))")
                                .font(.title)
                                .fontWeight(.medium)
                                .animation(.easeInOut(duration: 0.5), value: homeViewModel.diningScore)
                                .foregroundColor(Color.theme.background)
                        })
                    Text("Crowd")
                        .font(isTiny ? .title3 : .title2)
                        .fontWeight(.medium)
                        .foregroundColor(Color.theme.background)
                        .padding(.top,15)
                }
                Spacer()
                VStack(spacing: 0){
                    RatingGraphic(size: isTiny ? 50 : 65, strokewidth: 5, rating: homeViewModel.openStatusString.contains("Closed") || homeViewModel.numRatings == 0 ? 0.0 : CGFloat(homeViewModel.abundanceScore))
                        .frame(maxHeight: UIScreen.main.bounds.height/10)
                        .overlay(content: {
                            Text(homeViewModel.openStatusString.contains("Closed") || homeViewModel.numRatings == 0 ? "0" : homeViewModel.abundanceScore > 0.99 ? "\(Int(homeViewModel.abundanceScore * 100) - 1)" : "\(Int(homeViewModel.abundanceScore * 100))")
                                .font(.title)
                                .fontWeight(.medium)
                                .animation(.easeInOut(duration: 0.5), value: homeViewModel.diningScore)
                                .foregroundColor(Color.theme.background)
                        })
                    Text("Abundance")
                        .font(isTiny ? .title3 : .title2)
                        .fontWeight(.medium)
                        .foregroundColor(Color.theme.background)
                        .padding(.top,15)
                }
                Spacer()
                VStack(spacing: 0){
                    RatingGraphic(size: isTiny ? 50 : 65, strokewidth: 5, rating: homeViewModel.openStatusString.contains("Closed") || homeViewModel.numRatings == 0 ? 0.0 : CGFloat(homeViewModel.tasteScore))
                        .frame(maxHeight: UIScreen.main.bounds.height/10)
                        .overlay(content: {
                            Text(homeViewModel.openStatusString.contains("Closed") || homeViewModel.numRatings == 0 ? "0" : homeViewModel.tasteScore > 0.99 ? "\(Int(homeViewModel.tasteScore * 100) - 1)" : "\(Int(homeViewModel.tasteScore * 100))")
                                .font(.title)
                                .fontWeight(.medium)
                                .animation(.easeInOut(duration: 0.5), value: homeViewModel.diningScore)
                                .foregroundColor(Color.theme.background)
                        })
                    Text("Taste")
                        .font(isTiny ? .title3 : .title2)
                        .fontWeight(.medium)
                        .padding(.top,15)
                        .foregroundColor(Color.theme.background)
                }
                Spacer()
            }
            Text("\(!homeViewModel.lastUpdatedString.contains("Closed") && homeViewModel.numRatings == 0 ? "No ratings yet" : homeViewModel.lastUpdatedString)")
                .padding()
                .font(.callout)
                .fontWeight(.semibold)
                .italic()
                .foregroundStyle(Color.theme.background.opacity(0.5))
        }
        .opacity(homeViewModel.openStatusString.contains("Closed") ? 0.4 : 1.0)

    }
    
    struct ViewOffsetKey: PreferenceKey {
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
}


#Preview {
    NavigationStack {
        HomeView(showRatingPopUp: .constant(false))
            .navigationBarHidden(true)
    }
}
