//
//  MenusView.swift
//  CommonsDining
//
//  Created by Caden Cooley on 2/5/25.
//

import SwiftUI

struct MenusView: View {
    
    @EnvironmentObject var menuViewModel: MenuPageViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @State private var offset = CGFloat.zero
    @State var hasAppeared: Bool = false
    
    private var itemsForDisplay: [Item] {
        var items = menuViewModel.allItems
        if menuViewModel.currentFilter == "Favorites"{
            items = menuViewModel.favItemsList
        }
        if menuViewModel.currentFilter == "Tomorrow"{
            items = items.filter({$0.tomorrow == true})
        }
        if menuViewModel.searchText.isEmpty {
            return items
        }
        else {
            var searched: [Item] = menuViewModel.searchedItems
            if menuViewModel.currentFilter == "Favorites"{
                searched = searched.filter({$0.isFavorite})
            }
            if menuViewModel.currentFilter == "Tomorrow"{
                items = searched.filter({$0.tomorrow == true})
            }
            return searched
        }
    }
    
    var body: some View {
        ZStack {
            Image("MenuBack")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: UIScreen.main.bounds.width)
            
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white)
                    .frame(height: offset + 140 >= 0  ? offset + 140 > 300 ? 300 : offset + 140 : 0)
            }
            
            ScrollView(showsIndicators: false){
                header
                    .padding(.top, 60)
                VStack {
                    listSection
                        .background(
                            UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 20, bottomLeading: 0, bottomTrailing: 0, topTrailing: 20))
                                .fill(Color.theme.background)
                                .shadow(color: Color.theme.secondaryText.opacity(0.1), radius: 10, x: 0, y: -10))
                        .padding(.top, 100)
                }.background(GeometryReader {
                    Color.clear.preference(key: ViewOffsetKey.self,
                        value: -$0.frame(in: .named("scroll")).origin.y)
                })
                .onPreferenceChange(ViewOffsetKey.self) { newValue in
                    offset = newValue
                }
            }
        }
        .clipped()
        .ignoresSafeArea(edges: .top)
    }
    
    var header: some View {
            VStack {
                HStack {
                    Spacer()
                    Text("Item Catalog")
                        .font(.largeTitle)
                        .foregroundStyle(Color.theme.background)
                    Spacer()
                    Image(systemName: "bell")
                        .foregroundColor(Color.theme.red)
                        .onTapGesture {
                            print("notifications happeninng")
                        }
                }
                .padding()
            }
            .background(
                Rectangle()
                    .fill(Color.white.opacity(0.01))
                    .frame(height: 400)
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
            )
    }
    
    var listSection: some View {
        VStack (spacing: 0){
            if menuViewModel.menuIsLoading {
                SearchBarView(searchText: $menuViewModel.searchText)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .padding(.top, 30)
                filterButtons
                    .padding(.horizontal)
                    .padding(.bottom)
                VStack {
                    LazyVStack(spacing: 0){
                        ProgressView()
                        .padding(.horizontal)
                    }
                }
                .frame(minHeight: UIScreen.main.bounds.height/2)
            }
            else {
                SearchBarView(searchText: $menuViewModel.searchText)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .padding(.top, 30)
                filterButtons
                    .padding(.horizontal)
                    .padding(.bottom)
                VStack {
                    LazyVStack(spacing: 0){
                        ForEach(itemsForDisplay) { item in
                            MenuRow(showCheckmark: false, showSeen: false, showCategoryAndPeriod: true, item: item)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .padding(.vertical, 3)
                                .task {
                                    try? await menuViewModel.loadMoreIfNeeded(current: item)
                                }
                            Divider()
                        }
                        .padding(.horizontal)
                        if itemsForDisplay.count == 0 && menuViewModel.currentFilter == "Tomorrow"{
                            Text("No menus available for tomorrow")
                                .font(.headline)
                                .fontWeight(.medium)
                                .padding(.top, 30)
                        }
                        if itemsForDisplay.count > 10 && menuViewModel.searchText == "" {
                            ProgressView()
                                .padding(.top, 10)
                        }
                    }
                    Spacer()
                }
                .frame(minHeight: UIScreen.main.bounds.height/2)
            }
        }
        .task {
            if !hasAppeared {
                menuViewModel.menuIsLoading = true
                try? await menuViewModel.getAllItems()
                menuViewModel.menuIsLoading = false
                hasAppeared = true
            }
        }
    }
    
    var filterButtons: some View {
        Picker("Item Category", selection: $menuViewModel.currentFilter) {
            Text("All Items").tag("")
            Text("Favorites").tag("Favorites")
            Text("Tomorrow").tag("Tomorrow")
        }
        .pickerStyle(.segmented)
        .preferredColorScheme(.light)
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
    MenusView()
}
