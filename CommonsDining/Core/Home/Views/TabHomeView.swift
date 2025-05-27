//
//  TabHome.swift
//  CommonsDining
//
//  Created by Caden Cooley on 2/5/25.
//

import SwiftUI

import SwiftUI

// MARK: - Custom Tab Bar View
struct CustomTabBarView: View {
    var isTiny: Bool {
        return UIScreen.main.bounds.height < 700
    }
    let tabs: [TabBarItem]
    @Binding var selectedTab: TabBarItem

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                ForEach(tabs, id: \.self) { tab in
                    VStack {
                        Image(tab.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: isTiny ? 18 : 24, height: isTiny ? 18 : 24)
                        Text(tab.title)
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: 200)
                    .padding()
                    .foregroundColor(selectedTab == tab ? Color.theme.blue : .gray)
                    .onTapGesture {
                        selectedTab = tab
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 10)
            .background(Color.theme.background.shadow(color: Color.black.opacity(selectedTab.title == "Info" ? 0.05 : 0.2), radius: 10, y: -13))
//            .overlay(alignment: .top) {
//                Rectangle()
//                    .frame(width: nil, height: selectedTab.title == "Info" ? 1 : 0, alignment: .top)
//                    .foregroundColor(.black.opacity(0.2))
//                    .opacity(selectedTab.title == "Info" ? 1 : 0)
//            }
        }
        
    }
}

// MARK: - Container View
struct CustomTabBarContainerView<Content: View>: View {
    @Binding var selectedTab: TabBarItem
    @Binding var showRatingPopup: Bool
    let tabs: [TabBarItem]
    let content: Content

    init(tabs: [TabBarItem], selectedTab: Binding<TabBarItem>, showRatingPopup: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._selectedTab = selectedTab
        self._showRatingPopup = showRatingPopup
        self.tabs = tabs
        self.content = content()
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    content
                }
                CustomTabBarView(tabs: tabs, selectedTab: $selectedTab)
            }
            if showRatingPopup {
                BlurView(style: .dark)
                    .opacity(0.8)
                    .ignoresSafeArea()
            }
            if showRatingPopup {
                RatingPopUpView(showRatingPopUp: $showRatingPopup)
                    .transition(.move(edge: .leading))
            }
        }
    }
}

// MARK: - Home View
struct TabHomeView: View {
    let allTabs = [
        TabBarItem(iconName: "MenuIcon", title: "All Items"),
        TabBarItem(iconName: "HomeIcon", title: "Today"),
        TabBarItem(iconName: "InfoIcon", title: "Info"),
        TabBarItem(iconName: "InfoIcon", title: "Profile")
    ]
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var menuViewModel: MenuPageViewModel
    @EnvironmentObject var extraViewModel: ExtraInfoViewModel
    @State private var selectedTab: TabBarItem = TabBarItem(iconName: "HomeIcon", title: "Today")
    @State var showRatingPopup: Bool = false

    var body: some View {
        CustomTabBarContainerView(tabs: allTabs, selectedTab: $selectedTab, showRatingPopup: $showRatingPopup) {
            ZStack {
                MenusView()
                    .zIndex(selectedTab.title == "All Items" ? 1 : 0)
                    .opacity(selectedTab.title == "All Items" ? 1 : 0)
                    .allowsHitTesting(selectedTab.title == "All Items")
                HomeView(showRatingPopUp: $showRatingPopup)
                    .zIndex(selectedTab.title == "Today" ? 1 : 0)
                    .opacity(selectedTab.title == "Today" ? 1 : 0)
                    .allowsHitTesting(selectedTab.title == "Today")
                ExtraView()
                    .zIndex(selectedTab.title == "Info" ? 1 : 0)
                    .opacity(selectedTab.title == "Info" ? 1 : 0)
                    .allowsHitTesting(selectedTab.title == "Info")
                ProfileView()
                    .zIndex(selectedTab.title == "Profile" ? 1 : 0)
                    .opacity(selectedTab.title == "Profile" ? 1 : 0)
                    .allowsHitTesting(selectedTab.title == "Profile")
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        if horizontalAmount < -70 {
                            // Swiped left
                            onSwipeLeft()
                        } else if horizontalAmount > 70 {
                            // Swiped right
                            onSwipeRight()
                        }
                    }
            )
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "M/d"
                    let currentDate = formatter.string(from: Date())
                    
                    if currentDate != homeViewModel.currentDay {
                        Task {
                            homeViewModel.fullRefresh()
                            extraViewModel.fullRefresh()
                            try? await menuViewModel.getAllItems()
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func onSwipeLeft() {
        if selectedTab.title == "Today" {
            DispatchQueue.main.async {
                self.selectedTab = allTabs[2]
            }
        }
        else if selectedTab.title == "All Items" {
            DispatchQueue.main.async {
                self.selectedTab = allTabs[1]
            }
        }
    }
    
    func onSwipeRight() {
        if selectedTab.title == "Today" {
            DispatchQueue.main.async {
                self.selectedTab = allTabs[0]
            }
        }
        else if selectedTab.title == "Info" {
            DispatchQueue.main.async {
                self.selectedTab = allTabs[1]
            }
        }
    }
}

// MARK: - Preview
#Preview {
    TabHomeView()
}

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // do nothing
    }
}
