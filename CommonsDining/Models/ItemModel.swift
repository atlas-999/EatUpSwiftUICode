//
//  ItemModel.swift
//  CommonsDining
//
//  Created by Caden Cooley on 3/21/25.
//

import Foundation
import FirebaseFirestore

struct Item: Identifiable {
    let id: String
    let name: String
    let calories: Int
    let protein: Int
    let category: Category
    let period: Period
    let today: Bool
    let tomorrow: Bool
    let isFavorite: Bool
    let lastSeen: Date
    let keywords: [String]
    
    init(id: String, name: String, calories: Int, protein: Int, category: Category, period: Period, today: Bool, tomorrow: Bool, isFavorite: Bool, lastSeen: Date, keywords: [String]) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.category = category
        self.period = period
        self.today = today
        self.tomorrow = tomorrow
        self.isFavorite = isFavorite
        self.lastSeen = lastSeen
        self.keywords = keywords
    }
    
    func itemFavorited() -> Item {
        return Item(id: id, name: name, calories: calories, protein: protein, category: category, period: period, today: today, tomorrow: tomorrow, isFavorite: true, lastSeen: lastSeen, keywords: keywords)
    }
    
    func itemUnFavorited() -> Item {
        return Item(id: id, name: name, calories: calories, protein: protein, category: category, period: period, today: today, tomorrow: tomorrow, isFavorite: false, lastSeen: lastSeen, keywords: keywords)
    }
    
    func lastSeenString(lastSeenDate: Date) -> String {
        let interval = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: lastSeenDate, to: .now)
        let secondsSince = interval.second ?? 0
        let minutesSince = interval.minute ?? 0
        let hoursSince = interval.hour ?? 0
        let daysSince = interval.day ?? 0
        if daysSince > 2 {
            return "2+ days ago"
        }
        else {
            if daysSince == 0 {
                if hoursSince == 0 {
                    if minutesSince == 0 {
                        if secondsSince < 5 {
                            return "just now"
                        }
                        else {
                            return "\(secondsSince)s ago"
                        }
                    }
                    else {
                        return "\(minutesSince)m ago"
                    }
                }
                else {
                    return "\(hoursSince)h ago"
                }
            }
            else  {
                return "\(daysSince)d ago"
            }
        }
    }
}

enum Category: String, CaseIterable {
    case grill = "Grill"
    case latin = "Latin"
    case mainLine = "Main Line"
    case composeSandwich = "Compose Sandwich"
    case grillMadeToOrder = "Grill Made to Order"
    case saladBar = "Salad Bar"
    case innovation = "Innovation"
    case riceBar = "Rice Bar"
    case dessert = "Dessert"
    case pizzaPasta = "Pizza Pasta"
    case pizza = "Pizza"
    case vegan = "Vegan"
    case soup = "Soup"
    case hummusBar = "Hummus Bar"
    case composeSalad = "Compose Salad"
    case none = "None"
    
    var getSortOrder: Int {
        switch self {
        case .grill:
            return 1
        case .latin:
            return 3
        case .mainLine:
            return 2
        case .pizza:
            return 9
        case .composeSandwich:
            return 11
        case .grillMadeToOrder:
            return 8
        case .saladBar:
            return 12
        case .innovation:
            return 7
        case .riceBar:
            return 15
        case .dessert:
            return 6
        case .pizzaPasta:
            return 10
        case .vegan:
            return 4
        case .soup:
            return 5
        case .hummusBar:
            return 14
        case .composeSalad:
            return 13
        case .none:
            return 16
        }
    }
}

enum Period: String, CaseIterable, Hashable {
    case Breakfast = "Breakfast"
    case Brunch = "Brunch"
    case Lunch = "Lunch"
    case Dinner = "Dinner"
    case none = "None"
}
