//
//  UserManager.swift
//  CommonsDining
//
//  Created by Caden Cooley on 5/2/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class UserManager {
    
    @AppStorage("userId") var userId = ""
    @AppStorage("username") var username = ""
    
    static let shared = UserManager()
    
    private init() {}
    
    func createNewUser(user: AuthDataResultModel, name: String) async throws {
        let userData: [String:Any] = [
            "userId" : user.uid,
            "favorites" : [String](),
            "dateCreated" : Timestamp(),
            "fcmToken" : "",
            "username" : name,
            "numUserRatings" : 0
        ]
        try await Firestore.firestore().collection("Users").document(user.uid).setData(userData, merge: false)
        userId = user.uid
        username = name
        print("set user id: ", userId)
    }
}
