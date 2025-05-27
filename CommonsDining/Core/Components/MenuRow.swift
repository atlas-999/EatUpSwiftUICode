//
//  MenuRow.swift
//  CommonsDining
//
//  Created by Caden Cooley on 2/3/25.
//

import SwiftUI
import FirebaseFirestore

struct MenuRow: View {
    
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var menuViewModel: MenuPageViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State var showingPrePrompt: Bool = false
    
    @AppStorage("hasRequestedNotifications") var hasRequestedNotifications = false
    @AppStorage("hasEnabledNotifications") var hasEnabledNotifications = false
    @AppStorage("userId") var userId = ""
    
    @State var showChecked: Bool = false
    @State var lockSeen: String = ""
    
    let showCheckmark: Bool
    let showSeen: Bool
    let showCategoryAndPeriod: Bool
    let item: Item
    
    var body: some View {
        HStack {
            Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundColor(Color.theme.red)
                .onTapGesture {
                   heartTapped()
                }
            VStack (alignment: .leading, spacing: 3){
                Text(item.name)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.accentColor)
                    .fontWeight(.semibold)
                HStack {
                    Text("\(item.calories) Cal,")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.theme.secondaryTexasState)
                    Text("\(item.protein)g Protein")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.theme.secondaryTexasState)
                    if showSeen {
                        Circle()
                            .frame(width: 3, height: 3)
                            .foregroundColor(Color.theme.secondaryTexasState)
                        Text(lockSeen != "" ? "\(lockSeen)" : "\(item.lastSeenString(lastSeenDate: item.lastSeen))")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.theme.secondaryTexasState)
                            .opacity(showSeen ? 1.0 : 0.0)
                    }
                    if showCategoryAndPeriod {
                        Circle()
                            .frame(width: 3, height: 3)
                            .foregroundColor(Color.theme.secondaryTexasState)
                        HStack {
                            Text("\(item.period.rawValue)")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.theme.secondaryTexasState)
//                            Text(item.category.rawValue)
//                                .font(.system(size: 18))
//                                .foregroundStyle(Color.theme.secondaryTexasState)
                        }
                    }
                }
            }
            Spacer()
            if showCheckmark {
                Image(systemName: "checkmark.circle")
                    .font(.title2)
                    .foregroundColor(showChecked ? Color.theme.red : Color.theme.secondaryText)
                    .opacity(showCheckmark ? 1.0 : 0.0)
                    .animation(.bouncy(duration: 0.5), value: showChecked)
                    .onTapGesture {
                        lockSeen = "just now"
                        homeViewModel.updateLastSeen(id: item.id)
                        homeViewModel.refreshOneItem(id: item.id)
                        withAnimation (.bouncy) {
                            showChecked = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                showChecked = false
                        })
                    }
            }
        }
        .task {
            lockSeen = "\(item.lastSeenString(lastSeenDate: item.lastSeen))"
        }
        .alert("Get Notified About Your Favorite Meals?", isPresented: $showingPrePrompt) {
            Button("Maybe Later") {
                 // User declined our pre-prompt
                 showingPrePrompt = false
             }
             
             Button("Sure") {
                 showingPrePrompt = false
                 requestAndSubscribe()
             }
         } message: {
             Text("EatUp will send you a notification when one of your favorite items in on the menu.")
         }
    }

    func heartTapped() {
        print("Tapped")
        if hasRequestedNotifications == false {
            //show alert asking to send notis
            hasRequestedNotifications = true
            showingPrePrompt = true
        }
        if item.isFavorite {
            Task {
                try await homeViewModel.unFavoriteItem(item: item)
            }
            menuViewModel.unFavorite(item: item)
        }
        else {
            Task {
                try await homeViewModel.favoriteItem(item: item)
            }
            menuViewModel.favorite(item: item)
        }
    }
    
    private func requestAndSubscribe() {
        notificationManager.requestNotificationPermission(completion: { granted in
            if granted {
                hasEnabledNotifications = true
                notificationManager.subscribeToFavoriteUpdates { success in
                    print(success)
                }
                notificationManager.uploadFCMTokenToFirestore(userId: userId)
            }
        })
    }

}

#Preview {
    MenuRow(showCheckmark: true, showSeen: true, showCategoryAndPeriod: true, item: Item(id: "asdf", name: "Beef Chili", calories: 230, protein: 23, category: .mainLine, period: .Lunch, today: true, tomorrow: false, isFavorite: false, lastSeen: Date.now, keywords: ["key"]))
}
