//
//  FirebaseHoursManager.swift
//  CommonsDining
//
//  Created by Caden Cooley on 4/12/25.
//

import Foundation
import FirebaseFirestore

class FirebaseHoursManager {
    
    static let shared = FirebaseHoursManager()
    
    private let OpenStatusCollection = Firestore.firestore().collection("OpenStatus")
    
    
    func getOpenHours() async throws -> [String] {
        let snapshot = try await OpenStatusCollection.document("Commons").getDocument()
        
        var hoursArray: [String] = []
        
        if let hours = snapshot.data() {
            hoursArray.append(hours["Sunday"] as? String ?? "7:00-3:30, 4:00-10:00")
            hoursArray.append(hours["Monday"] as? String ?? "7:00-3:30, 4:00-10:00")
            hoursArray.append(hours["Tuesday"] as? String ?? "7:00-3:30, 4:00-10:00")
            hoursArray.append(hours["Wednesday"] as? String ?? "7:00-3:30, 4:00-10:00")
            hoursArray.append(hours["Thursday"] as? String ?? "7:00-3:30, 4:00-10:00")
            hoursArray.append(hours["Friday"] as? String ?? "7:00-3:30, 4:00-10:00")
            hoursArray.append(hours["Saturday"] as? String ?? "7:00-3:30, 4:00-10:00")
        }
        
        return hoursArray
    }

}
