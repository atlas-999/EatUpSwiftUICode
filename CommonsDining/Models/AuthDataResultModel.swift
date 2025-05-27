//
//  AuthDataResultModel.swift
//  CommonsDining
//
//  Created by Caden Cooley on 5/2/25.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    
    let email: String?
    let uid: String
    let isAnonymous: Bool?
    let photoURL: String?
    
    init(user: User) {
        self.email = user.email
        self.uid = user.uid
        self.isAnonymous = user.isAnonymous
        self.photoURL = user.photoURL?.absoluteString
    }
    
}
