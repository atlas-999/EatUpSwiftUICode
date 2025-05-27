//
//  ExtraInfoViewModel.swift
//  CommonsDining
//
//  Created by Caden Cooley on 4/20/25.
//

import Foundation

@MainActor
class ExtraInfoViewModel: ObservableObject {
    
    let weekday = Calendar.current.component(.weekday, from: Date())
    
    @Published var pastdays: [String] = []
    @Published var weeklyScores: [Float] = []
    @Published var weeklyHours: Array<(key: String, value: String)> = []
    @Published var weeklyHoursLoading: Bool = false
    
    init() {
        self.pastdays = getPastDays()
    }
    
    func fullRefresh() {
        getWeeklyHours()
        getWeeklyScores()
    }
    
    func getPastDays() -> [String] {
        let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var returnedOrder: [String] = []
        for i in 1...7 {
            let index = ((weekday - i) + weekdays.count) % weekdays.count
            returnedOrder.append(weekdays[index]) // Append normally, no insert at 0
        }
        return returnedOrder
    }
    
    func getWeeklyScores() {
        Task {
            let weeklyScores = try await FirebaseRatingsManager.shared.getPastRatings()
            
            print("WEEKLY Scores", weeklyScores)
            
            self.weeklyScores = weeklyScores
        }
    }
    
    func getWeeklyHours() {
        Task {
            weeklyHoursLoading = true
            let weeklyHours = try await FirebaseHoursManager.shared.getOpenHours()
            
            let weeklyHoursDict = [
                "Sunday": convertTo12HourFormat(weeklyHours[0]),
                "Monday": convertTo12HourFormat(weeklyHours[1]),
                "Tuesday": convertTo12HourFormat(weeklyHours[2]),
                "Wednesday": convertTo12HourFormat(weeklyHours[3]),
                "Thursday": convertTo12HourFormat(weeklyHours[4]),
                "Friday": convertTo12HourFormat(weeklyHours[5]),
                "Saturday": convertTo12HourFormat(weeklyHours[6])
            ]
            
            let newDict: [String: String] = combineConsecutiveDays(weeklyHoursDict)
            print("new dict", newDict)
            
            // Sort the dictionary by weekday order
            let weekOrder = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

            // Convert the dictionary into a sorted array of tuples
            let sortedHours = newDict.sorted {
                let firstKey = $0.key.components(separatedBy: "-").first ?? $0.key
                let secondKey = $1.key.components(separatedBy: "-").first ?? $1.key
                
                guard let firstIndex = weekOrder.firstIndex(of: firstKey),
                      let secondIndex = weekOrder.firstIndex(of: secondKey) else { return false }
                return firstIndex < secondIndex
            }
            
            // Store the sorted array (now a random access collection)
            self.weeklyHours = sortedHours // This should be an array of tuples [(key, value)]
            weeklyHoursLoading = false
        }
    }
    func combineConsecutiveDays(_ hoursDict: [String: String]) -> [String: String] {
        let orderedDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        var result: [String: String] = [:]
        
        var startDay: String? = nil
        var currentValue: String? = nil
        var currentRange: [String] = []

        for day in orderedDays {
            guard let value = hoursDict[day] else { continue }
            
            if currentValue == nil {
                // First entry
                startDay = day
                currentValue = value
                currentRange = [day]
            } else if value == currentValue {
                // Same as previous, extend range
                currentRange.append(day)
            } else {
                // Value changed, commit the previous group
                if currentRange.count == 1 {
                    result[currentRange[0]] = currentValue
                } else if let start = startDay {
                    result["\(start)-\(currentRange.last!)"] = currentValue
                }
                // Start new group
                startDay = day
                currentValue = value
                currentRange = [day]
            }
        }

        // Final group
        if currentRange.count == 1 {
            result[currentRange[0]] = currentValue
        } else if let start = startDay {
            result["\(start)-\(currentRange.last!)"] = currentValue
        }

        return result
    }
    
    func convertTo12HourFormat(_ input: String) -> String {
        // Split on comma to separate time ranges
        let ranges = input.split(separator: ",")
        
        // Helper to format a single time to "h:mm[a|p]"
        func formatTime(_ time: String) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "H:mm"
            
            guard let date = formatter.date(from: String(time)) else {
                return String(time) // fallback
            }

            formatter.dateFormat = "h:mm a"
            var formatted = formatter.string(from: date)

            // Format to "10:00a" instead of "10:00 AM"
            formatted = formatted
                .replacingOccurrences(of: " AM", with: "a")
                .replacingOccurrences(of: " PM", with: "p")

            return formatted
        }
        
        var formattedRanges: [String] = []

        for range in ranges {
            let trimmedRange = range.trimmingCharacters(in: .whitespaces)
            let times = trimmedRange.split(separator: "-")
            if times.count == 2 {
                let start = formatTime(String(times[0]))
                let end = formatTime(String(times[1]))
                formattedRanges.append("\(start) - \(end)")
            } else {
                formattedRanges.append(trimmedRange)
            }
        }
        
        return formattedRanges.joined(separator: ", ")
    }
}
