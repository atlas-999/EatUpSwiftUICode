//
//  MenuPageViewModel.swift
//  CommonsDining
//
//  Created by Caden Cooley on 3/30/25.
//

import Foundation
import Combine

@MainActor
class MenuPageViewModel: ObservableObject {
    
    @Published var allItems: [Item] = []
    @Published var searchText: String = ""
    @Published var menuIsLoading: Bool = false
    @Published var currentFilter: String = ""
    @Published var searchedItems: [Item] = []
    @Published var favItemsList: [Item] = []
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        $searchText
            .sink(receiveValue: { _ in
                self.fetchItemsFromSearch()
            })
            .store(in: &cancellables)
        
        $currentFilter
            .sink(receiveValue: { _ in
                self.fetchFavorites()
            })
            .store(in: &cancellables)
    }
    
    func getAllItems() async throws {
        self.allItems = try await FirebaseItemsManager.shared.getAllItems(currentItems: allItems)
    }
    
    func loadMoreIfNeeded(current: Item) async throws {
        guard allItems.count > 0 && current.id == allItems.last!.id else { return }
        try await self.getAllItems()
    }
    
    func fetchItemsFromSearch() {
        Task {
            let items = try await FirebaseItemsManager.shared.fetchItemsFromSearch(keyword: searchText)
            self.searchedItems = items
        }
    }
    
    func changeDayFilter(day: String) {
        self.currentFilter = day
    }
    
    func favorite(item: Item) {
        if let index = allItems.firstIndex(where: {$0.id == item.id}) {
            allItems[index] = item.itemFavorited()
        }
        if searchedItems.count > 0 {
            if let index = searchedItems.firstIndex(where: {$0.id == item.id}) {
                searchedItems[index] = item.itemFavorited()
            }
        }
        self.favItemsList.append(item.itemFavorited())
    }
    
    func unFavorite(item: Item) {
        if let index = allItems.firstIndex(where: {$0.id == item.id}) {
            allItems[index] = item.itemUnFavorited()
        }
        if searchedItems.count > 0 {
            if let index = searchedItems.firstIndex(where: {$0.id == item.id}) {
                searchedItems[index] = item.itemUnFavorited()
            }
        }
        if let index = favItemsList.firstIndex(where: {$0.id == item.id}) {
            favItemsList.remove(at: index)
        }
    }
    
    func fetchFavorites() {
        print("favorites checking")
        CoreDataManager.shared.getFavoritedItems(completion: { [weak self] favorites in
            let ids = favorites.map { $0.id! }
            if self?.favItemsList.count != favorites.count {
                Task {
                    var favs = try await FirebaseItemsManager.shared.getItemsWithIds(ids: ids)
                    self?.favItemsList = favs
                }
            }
        })
    }
}
