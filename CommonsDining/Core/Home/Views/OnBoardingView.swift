//
//  OnBoardingView.swift
//  CommonsDining
//
//  Created by Caden Cooley on 5/2/25.
//

import SwiftUI

struct OnBoardingView: View {
    
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    @StateObject var onBoardingVm = OnBoardingViewModel()
    @State var isLoading = false
    @State var nameText: String = ""
    
    var body: some View {
        
        ZStack {
            Image("Launch")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            VStack {
                Image("EatEm")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 250)
                    .foregroundColor(.white)
                    .padding(.vertical, 30)
                Image("icons")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 225)
                    .foregroundColor(.white)
                    .padding(.vertical, 30)
                Text("The all in one dining hall app. Live menus, weekly hours, and real-time ratings.")
                    .foregroundStyle(Color.white)
                    .font(.headline)
                    .frame(width: 250)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)
                TextField("Enter a name", text: $nameText)
                if !isLoading {
                    Text("Get Started".uppercased())
                        .font(.subheadline)
                        .foregroundStyle(Color.theme.blue)
                        .frame(width: 150, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                        )
                        .padding(.vertical)
                        .onTapGesture {
                            if !nameText.isEmpty {
                                isLoading = true
                                Task {
                                    do {
                                        try await onBoardingVm.signInAnonymous(name: nameText)
                                        hasOnboarded = true
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        }
                        .opacity(nameText.isEmpty ? 0.3 : 1)
                }
                else {
                    ProgressView()
                        .tint(.white)
                        .padding(.vertical, 31)
                }
            }
        }
    }
}

#Preview {
    OnBoardingView()
}
