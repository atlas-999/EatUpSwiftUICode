//
//  FirebaseRatingsManager.swift
//  CommonsDining
//
//  Created by Caden Cooley on 4/8/25.
//

import Foundation
import FirebaseFirestore
import NotificationCenter

class FirebaseRatingsManager {
    
    static let shared = FirebaseRatingsManager()
    
    private let ratingsCollection = Firestore.firestore().collection("Ratings")
    
    func getCurrentDay() async throws -> String {
        let snapshot = try await ratingsCollection.document("CurrentDay").getDocument()
        
        var date = ""
        
        if let data = snapshot.data() {
            if let timestamp = data["date"] as? Timestamp {
                let newdate = timestamp.dateValue()
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d"
                formatter.timeZone = TimeZone(abbreviation: "CST")
                let dateString = formatter.string(from: newdate)
                date = dateString
            }
        }
        
        return date
    }
    
    func getDiningScores() async throws -> ([Float], Int, Date?, Int) {
        let snapshot = try await ratingsCollection.document("CurrentRatings").getDocument()
        
        var scores: [Float] = []
        var numRatings: Int = 0
        var numDailyRatings: Int = 0
        var lastRating: Date? = nil
        
        if let ratings = snapshot.data() {
            scores.append(ratings["diningScore"] as? Float ?? 0.0)
            scores.append(ratings["crowdScore"] as? Float ?? 0.0)
            scores.append(ratings["abundanceScore"] as? Float ?? 0.0)
            scores.append(ratings["tasteScore"] as? Float ?? 0.0)
            scores.append(ratings["dailyAvg"] as? Float ?? 0.0)
            numDailyRatings = ratings["numDailyRatings"] as? Int ?? 0
            numRatings = ratings["numRatings"] as? Int ?? 0

            let isoDate = ratings["lastRating"] as? String
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "CST")
            let date = dateFormatter.date(from:isoDate ?? "2025-01-01T10:44:00+0000") ?? Date.now
            lastRating = date
        }

        return (scores, numRatings, lastRating, numDailyRatings)
    }
    
    func sendRatings(diningScore: Float, crowdScore: Float, abundanceScore: Float, tasteScore: Float, numRatings: Int, dailyAvg: Float, numDailyRatings: Int) async throws {
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "CST")
        let date = dateFormatter.string(from: Date.now)
        
        try await ratingsCollection.document("CurrentRatings").setData([
          "diningScore": diningScore,
          "crowdScore": crowdScore,
          "abundanceScore": abundanceScore,
          "tasteScore": tasteScore,
          "numRatings": numRatings + 1,
          "lastRating" : date,
          "dailyAvg" : dailyAvg,
          "numDailyRatings" : numDailyRatings + 1
        ])
    }
    
    func getPastRatings() async throws -> [Float] {
        let snapshot = try await ratingsCollection.document("WeeklyAvgScores").getDocument()
        
        print(snapshot)
        
        var weeklyScores: [Float] = []
        
        if let ratings = snapshot.data() {
            weeklyScores.append(ratings["1dayPast"] as? Float ?? 0.0)
            weeklyScores.append(ratings["2dayPast"] as? Float ?? 0.0)
            weeklyScores.append(ratings["3dayPast"] as? Float ?? 0.0)
            weeklyScores.append(ratings["4dayPast"] as? Float ?? 0.0)
            weeklyScores.append(ratings["5dayPast"] as? Float ?? 0.0)
            weeklyScores.append(ratings["6dayPast"] as? Float ?? 0.0)
        }
        
        return weeklyScores
    }

}
