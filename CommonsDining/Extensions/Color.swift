//
//  Color.swift
//  CommonsDining
//
//  Created by Caden Cooley on 2/2/25.
//

import Foundation
import SwiftUI

extension Color {
    
    static let theme = ColorTheme()
    
}

struct ColorTheme {
    
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let secondaryText = Color("SecondaryTextColor")
    let tertiaryText = Color("TertiaryTextColor")
    let texasState = Color("TexasStateTheme")
    let secondaryTexasState = Color("SecondaryTexasState")
    let red = Color("Red")
    let blue = Color("Blue")
    let secondaryBlue = Color("SecondaryBlue")
    let ratingRed = Color("RatingRed")
}
