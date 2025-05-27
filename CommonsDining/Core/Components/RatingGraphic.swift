//
//  RatingArc.swift
//  CommonsDining
//
//  Created by Caden Cooley on 2/8/25.
//

import SwiftUI

struct RatingGraphic: View {
    
    var size: CGFloat
    var strokewidth: CGFloat
    var rating: CGFloat
    
    private let gradient = AngularGradient(
        stops: [Gradient.Stop(color: Color.theme.background, location: 0.45), Gradient.Stop(color: Color.theme.ratingRed, location: 1)],
        center: .center,
        startAngle: .degrees(360),
        endAngle: .degrees(180))
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: strokewidth)
                .frame(width: size)
                .foregroundColor(Color.gray.opacity(0.15))
            
            Circle()
                .trim(from: 0.02, to: rating*0.98)
                .rotation(Angle(degrees: 90))
                .stroke(style: StrokeStyle(lineWidth: strokewidth, lineCap: .round))
                .frame(width: size)
                .foregroundStyle(gradient)
                .animation(.spring(duration: 0.5), value: rating)
        }
    }
        
}

struct RatingGraphic2: View {
    var size: CGFloat
    var strokewidth: CGFloat
    var rating: CGFloat
    
    private let gradient = AngularGradient(
        stops: [Gradient.Stop(color: Color.theme.ratingRed, location: 0.5), Gradient.Stop(color: Color.theme.blue.opacity(0.35), location: 0.85), Gradient.Stop(color: Color.theme.blue, location: 1)],
        center: .center,
        startAngle: .degrees(360),
        endAngle: .degrees(180))
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: strokewidth)
                .frame(width: size)
                .foregroundColor(Color.gray.opacity(0.15))
            
            Circle()
                .trim(from: 0.02, to: rating*0.98)
                .rotation(Angle(degrees: 90))
                .stroke(style: StrokeStyle(lineWidth: strokewidth, lineCap: .round))
                .frame(width: size)
                .foregroundStyle(gradient)
                .animation(.spring(duration: 0.5), value: rating)
        }
    }
}

struct RatingArc: Shape {
    func path(in rect: CGRect) -> Path { Path {
        path in
        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.height / 2, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 135), clockwise: true)
        
    }
    }
}

#Preview {
    RatingGraphic(size: 300, strokewidth: 25, rating: 0.9)
        .frame(maxHeight: UIScreen.main.bounds.height/3)
}
