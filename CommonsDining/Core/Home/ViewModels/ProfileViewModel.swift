//
//  ProfileViewModel.swift
//  CommonsDining
//
//  Created by Caden Cooley on 5/26/25.
//

import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    
    @AppStorage("username") var username: String = ""
    
}
