//
//  TodaysMenuView.swift
//  CommonsDining
//
//  Created by Caden Cooley on 2/15/25.
//

import SwiftUI

struct TodaysMenuView: View {
    
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @State var hasAppeared: Bool = false
    
    private var itemsForDisplay: [Item] {
        return homeViewModel.currentPeriod != nil ? homeViewModel.todaysItems.filter({$0.period == homeViewModel.currentPeriod}) : homeViewModel.todaysItems
    }

    var body: some View {
            ScrollView(showsIndicators: false) {
                if homeViewModel.menuIsLoading {
                    ProgressView()
                }
                else if homeViewModel.todaysItems.count == 0 {
                    Text("No menus available for today")
                        .font(.headline)
                        .fontWeight(.medium)
                        .padding(.top, 30)
                }
                else {
                    LazyVStack {
                        ForEach(itemsForDisplay) { item in
                            MenuRow(showCheckmark: true, showSeen: true, showCategoryAndPeriod: false, item: item)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                            Divider()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(alignment: .center)
            .padding()
            .background(
                Rectangle().fill(Color.theme.background)
            )
            .task {
                if !hasAppeared {
                    homeViewModel.menuIsLoading = true
                    try? await homeViewModel.getTodaysItems()
                    homeViewModel.menuIsLoading = false
                    hasAppeared = true
                }
                homeViewModel.refreshAllItems()
            }
            
            
    }
}

#Preview {
    TodaysMenuView()
}
