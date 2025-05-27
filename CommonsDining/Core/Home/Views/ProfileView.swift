//
//  ProfileView.swift
//  CommonsDining
//
//  Created by Caden Cooley on 5/26/25.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack {
            Text("This is the profile page")
            
            Text("USERNAME: \(profileViewModel.username)")
        }
    }
}

#Preview {
    ProfileView()
}
