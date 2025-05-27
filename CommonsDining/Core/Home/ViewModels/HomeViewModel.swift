//
//  HomeViewModel.swift
//  CommonsDining
//
//  Created by Caden Cooley on 3/21/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    
    @AppStorage("userId") var userId: String = ""
    @AppStorage("lastRated") var lastRated: Double = 0.0
    @Published var currentDay: String = ""
    @Published var diningScore: Float = 0.5
    @Published var crowdScore: Float = 0.5
    @Published var abundanceScore: Float = 0.5
    @Published var tasteScore: Float = 0.5
    @Published var lastUpdatedString: String = ""
    @Published var todaysItems: [Item] = []
    @Published var currentPeriod: Period = .Breakfast
    @Published var menuIsLoading: Bool = false
    @Published var openStatusString: String = ""
    @Published var numRatings: Int = 0
    
    private let coreDataManager = CoreDataManager()
    
    func getTodaysDate() {
        Task {
            let date = try await FirebaseRatingsManager.shared.getCurrentDay()
            currentDay = date
        }
    }
    
    func fullRefresh() {
        Task {
            getOpenStatusString()
            try? await getTodaysRatingsAsync()
            menuIsLoading = true
            try? await getTodaysItems()
            menuIsLoading = false
        }
    }
    
    func getTodaysHours() async throws -> String {
        let weekday = Calendar.current.component(.weekday, from: Date())
        var todaysHours = ""
        let hours = try await FirebaseHoursManager.shared.getOpenHours()
        todaysHours = hours[weekday-1]
        return todaysHours
    }
    
    func getOpenStatusString() {
        Task {
            let hours = try await getTodaysHours()
            
            let date = Date()
            var calendar = Calendar.current
            if let timeZone = TimeZone(identifier: "CST") {
               calendar.timeZone = timeZone
            }
            let currentTime = HourAndMinute(hour: calendar.component(.hour, from: date), minute: calendar.component(.minute, from: date))
            var finalText = "Closed for the day"
            let timeInts = hours.contains(",") ? hours.split(separator: ",").map { String($0) } : [hours]
            var openingTimes: [HourAndMinute] = []
            var closingTimes: [HourAndMinute] = []
            for i in 0..<timeInts.count {
                var ourInt = i != 0 ? String(timeInts[i].dropFirst()) : timeInts[i]
                openingTimes.append(HourAndMinute(hour: Int(String(ourInt.split(separator: "-")[0]).split(separator: ":")[0])!, minute:Int(String(ourInt.split(separator: "-")[0]).split(separator: ":")[1])!))
                closingTimes.append(HourAndMinute(hour: Int(String(ourInt.split(separator: "-")[1]).split(separator: ":")[0])!, minute: Int(String(ourInt.split(separator: "-")[1]).split(separator: ":")[1])!))
            }
            for i in 0..<openingTimes.count {
                if currentTime < openingTimes[i] {
                    finalText = "Closed - Opens at \(openingTimes[i].toString())"
                    break
                }

                if currentTime >= openingTimes[i] && currentTime < closingTimes[i] {
                    finalText = "Open - Closes at \(closingTimes[i].toString())"
                    break
                }
            }
            self.openStatusString = finalText
        }
    }

    func getTodaysRatings() {
        Task {
            var ratingVals = try await FirebaseRatingsManager.shared.getDiningScores()
            
            if openStatusString.contains("Closed") && ratingVals.1 != 0 {
                try await FirebaseRatingsManager.shared.sendRatings(diningScore: 0.5, crowdScore: 0.5, abundanceScore: 0.5, tasteScore: tasteScore, numRatings: 0, dailyAvg: ratingVals.0[4], numDailyRatings: ratingVals.3)
                ratingVals = try await FirebaseRatingsManager.shared.getDiningScores()
            }
            
            self.diningScore = ratingVals.0[0]
            self.crowdScore = ratingVals.0[1]
            self.abundanceScore = ratingVals.0[2]
            self.tasteScore = ratingVals.0[3]
            self.numRatings = ratingVals.1
            self.lastUpdatedString = getLastUpdatedString(lastRated: ratingVals.2 ?? Date.now)
        }
    }
    
    func getTodaysRatingsAsync() async throws {
        var ratingVals = try await FirebaseRatingsManager.shared.getDiningScores()
        
        if openStatusString.contains("Closed") && ratingVals.1 != 0 {
            try await FirebaseRatingsManager.shared.sendRatings(diningScore: 0.5, crowdScore: 0.5, abundanceScore: 0.5, tasteScore: tasteScore, numRatings: -1, dailyAvg: ratingVals.0[4], numDailyRatings: ratingVals.3)
            ratingVals = try await FirebaseRatingsManager.shared.getDiningScores()
        }
        
        self.diningScore = ratingVals.0[0]
        self.crowdScore = ratingVals.0[1]
        self.abundanceScore = ratingVals.0[2]
        self.tasteScore = ratingVals.0[3]
        self.numRatings = ratingVals.1
        self.lastUpdatedString = getLastUpdatedString(lastRated: ratingVals.2 ?? Date.now)
    }
    
    func sendRating(crowd: Float, abundance: Float, taste: Float) {
        Task {
            let ratings = try await FirebaseRatingsManager.shared.getDiningScores()
            let numRatings = Float(ratings.1)
            let crowdScore = calculateNewAverage(old: ratings.0[1], new: crowd, numRatings: numRatings)
            let abundanceScore = calculateNewAverage(old: ratings.0[2], new: abundance, numRatings: numRatings)
            let tasteScore = calculateNewAverage(old: ratings.0[3], new: taste, numRatings: numRatings)
            let diningScore = (crowdScore + abundanceScore + tasteScore)/3
            let numDailyRatings = Float(ratings.3)
            let dailyAvg = calculateNewAverage(old: ratings.0[4], new: ((crowd + abundance + taste)/3), numRatings: numDailyRatings)
            
            do {
                try await FirebaseRatingsManager.shared.sendRatings(diningScore: diningScore, crowdScore: crowdScore, abundanceScore: abundanceScore, tasteScore: tasteScore, numRatings: Int(numRatings), dailyAvg: dailyAvg, numDailyRatings: Int(numDailyRatings))
                lastRated = Date().timeIntervalSince1970
            }
            
            let ratingVals = try await FirebaseRatingsManager.shared.getDiningScores()
            
            self.diningScore = ratingVals.0[0]
            self.crowdScore = ratingVals.0[1]
            self.abundanceScore = ratingVals.0[2]
            self.tasteScore = ratingVals.0[3]
            self.numRatings = Int(numRatings+1)
            self.lastUpdatedString = getLastUpdatedString(lastRated: ratingVals.2 ?? Date.now)
        }
    }
        
    func calculateNewAverage(old: Float, new: Float, numRatings: Float) -> Float {
        return ((old * numRatings) + new)/(numRatings+1)
    }
    
    func getTodaysItems() async throws {
        var items = try await FirebaseItemsManager.shared.getTodaysItems()
        items = FirebaseItemsManager.shared.sortItems(items: items)
        self.todaysItems = items
        getTodaysDate()
    }
    
    func changeFilter(period: Period) {
        self.currentPeriod = period
    }

    func favoriteItem(item: Item) async throws {
        if let index = todaysItems.firstIndex(where: {$0.id == item.id}) {
            todaysItems[index] = item.itemFavorited()
        }
        coreDataManager.addFavorite(item: item)
        print(userId)
        try await FirebaseItemsManager.shared.favoriteItemInDB(itemId: item.id, userId: userId)
    }
    
    func unFavoriteItem(item: Item) async throws {
        if let index = todaysItems.firstIndex(where: {$0.id == item.id}) {
            todaysItems[index] = item.itemUnFavorited()
        }
        coreDataManager.deleteFavorite(id: item.id)
        print(userId)
        try await FirebaseItemsManager.shared.unFavoriteItemInDB(itemId: item.id, userId: userId)
    }
    
    func updateLastSeen(id: String) {
        Task {
            await FirebaseItemsManager.shared.updateLastSeen(id: id)
        }
    }
    
    func refreshOneItem(id: String) {
        Task {
            if let index = todaysItems.firstIndex(where: {$0.id == id}) {
                todaysItems[index] = try await FirebaseItemsManager.shared.getOneItem(id: id)
            }
        }
    }
    
    func refreshAllItems() {
        self.todaysItems = todaysItems
    }
    
    func getLastUpdatedString(lastRated: Date) -> String {
        let interval = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: lastRated, to: .now)
        let secondsSince = interval.second ?? 0
        let minutesSince = interval.minute ?? 0
        let hoursSince = interval.hour ?? 0
        let daysSince = interval.day ?? 0
        if daysSince > 2 {
            return "Last updated more than 2 days ago"
        }
        else {
            if daysSince == 0 {
                if hoursSince == 0 {
                    if minutesSince == 0 {
                        if secondsSince < 5 {
                            return "Updated just now"
                        }
                        else {
                            return "Updated \(secondsSince)s ago"
                        }
                    }
                    else {
                        return "Updated \(minutesSince)m ago"
                    }
                }
                else {
                    return "Updated \(hoursSince)h ago"
                }
            }
            else  {
                return "Updated \(daysSince)d ago"
            }
        }
    }
    
    func getDailyPeriods() -> [Period] {
        var currentPeriods: [Period] = []
        for item in todaysItems {
            if !currentPeriods.contains(item.period) {
                currentPeriods.append(item.period)
            }
        }
        let order: [Period] = [.Breakfast, .Brunch, .Lunch, .Dinner]

        currentPeriods = currentPeriods.sorted {
            order.firstIndex(of: $0)! < order.firstIndex(of: $1)!
        }
        return currentPeriods
    }

}
