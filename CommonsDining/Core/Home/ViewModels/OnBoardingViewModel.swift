//
//  OnBoardingViewModel.swift
//  CommonsDining
//
//  Created by Caden Cooley on 5/2/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

@MainActor
class OnBoardingViewModel: ObservableObject {
    
    @State var isLoading: Bool = false
    
    func signInAnonymous(name: String) async throws {
        isLoading = true
        let newUser = try await AuthenticationManager.shared.signInAnonymous()
        try await UserManager.shared.createNewUser(user: newUser, name: name)
        isLoading = false
    }
}
