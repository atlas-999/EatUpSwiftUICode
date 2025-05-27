//
//  RatingPopUpView.swift
//  CommonsDining
//
//  Created by Caden Cooley on 4/8/25.
//

import SwiftUI

struct RatingPopUpView: View {
    
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @Binding var showRatingPopUp: Bool
    @State var crowdRating: Float = 0
    @State var abundanceRating: Float = 0
    @State var tasteRating: Float = 0
        
    var body: some View {
        ZStack {
            VStack(spacing: 0){
                VStack {
                    Text("Rate this Place!")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.theme.background)
                    Text("Tap to Rate Commons Dining")
                        .font(.callout)
                        .foregroundStyle(Color.theme.background.opacity(0.5))
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(
                    Image("MenuBack")
                )
                VStack {
                    VStack (alignment: .leading){
                        Text("How Busy is It?")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("The amount of people in the dining hall.")
                            .foregroundStyle(Color.theme.blue.opacity(0.7))
                            .font(.callout)
                        HStack {
                            RateButton(isSelected: crowdRating == 1 ? true : false, ratingText: "Busy")
                                .onTapGesture {
                                    crowdRating = 1
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 37)
                            RateButton(isSelected: crowdRating == 2 ? true : false, ratingText: "OK")
                                .onTapGesture {
                                    crowdRating = 2
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 37)
                            RateButton(isSelected: crowdRating == 3 ? true : false, ratingText: "Empty")
                                .onTapGesture {
                                    crowdRating = 3
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 37)
                        }
                        .padding(.vertical, 7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    Spacer()
                    VStack (alignment: .leading){
                        Text("How Much is Left?")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("The amount of each item remaining.")
                            .foregroundStyle(Color.theme.blue.opacity(0.7))
                            .font(.callout)
                        HStack() {
                            RateButton(isSelected: abundanceRating == 1 ? true : false, ratingText: "A Little")
                                .onTapGesture {
                                    abundanceRating = 1
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 37)
                            RateButton(isSelected: abundanceRating == 2 ? true : false, ratingText: "Some")
                                .onTapGesture {
                                    abundanceRating = 2
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 37)
                            RateButton(isSelected: abundanceRating == 3 ? true : false, ratingText: "A Lot")
                                .onTapGesture {
                                    abundanceRating = 3
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 37)
                                
                        }
                        .padding(.vertical, 7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    Spacer()
                    VStack (alignment: .leading){
                        Text("How Good is the Food?")
                            .font(.title2)
                            .fontWeight(.medium)
                        Text("The general taste of the food today.")
                            .foregroundStyle(Color.theme.blue.opacity(0.7))
                            .font(.callout)
                        HStack() {
                            RateButton(isSelected: tasteRating == 1 ? true : false, ratingText: "Bad")
                                .onTapGesture {
                                    tasteRating = 1
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 37)
                            RateButton(isSelected: tasteRating == 2 ? true : false, ratingText: "OK")
                                .onTapGesture {
                                    tasteRating = 2
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 37)
                            RateButton(isSelected: tasteRating == 3 ? true : false, ratingText: "Tasty")
                                .onTapGesture {
                                    tasteRating = 3
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 37)
                        }
                        .padding(.vertical, 7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    Spacer()
                    HStack(){
                        RateButton(isSelected: false, ratingText: "CANCEL")
                            .onTapGesture {
                                showRatingPopUp = false
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 47)
                        RateButton(isSelected: true, ratingText: "DONE")
                            .onTapGesture {
                                if crowdRating > 0 && tasteRating > 0 && abundanceRating > 0 {
                                    homeViewModel.sendRating(crowd: 0.5 * (crowdRating - 1), abundance: 0.5 * (abundanceRating - 1), taste: 0.5 * (tasteRating - 1))
                                    showRatingPopUp = false
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 47)
                            .opacity(crowdRating > 0 && tasteRating > 0 && abundanceRating > 0 ? 1 : 0.4)
                    }
                    .padding(.vertical)
                    .padding(.bottom, 5)
                    .padding(.horizontal, 20)
                    Spacer()
                }
                .padding(.top)
                .background(Color.theme.background)
            }
        }
        .frame(width: UIScreen.main.bounds.width/1.10, height: UIScreen.main.bounds.height/1.55)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
    
#Preview {
    RatingPopUpView(showRatingPopUp: .constant(true))
}
    

