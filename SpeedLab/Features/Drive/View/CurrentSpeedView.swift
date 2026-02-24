//
//  CurrentSpeedView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 29.01.2026.
//

import SwiftUI

struct CurrentSpeedView: View {
    let speed: Double
    let maxDisplaySpeed: Double = 300.0
    
    var body: some View {
        ZStack{
            Circle()
                .trim(from:0.1,to : 0.9)
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(90))
            
            Circle()
                .trim(from: 0.1, to: calculateTrim())
                .stroke(AngularGradient(gradient: Gradient(colors: [.acidGreen, .green,.yellow, .orange ,.red, .red]),
                                               center: .center, startAngle: .degrees(0),
                                               endAngle: .degrees(360)),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(90))
                .shadow(color: .green.opacity(0.5), radius: 10, x: 0, y: 0)
                .animation(.easeInOut(duration:0.1),value: speed)
                
            VStack(spacing: 10){
                Text("CURRENT SPEED")
                    .font(.spaceLightFont(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Text("\(Int(speed))")
                    .font(.spaceBoldFont(size: 60))
                                    .foregroundColor(.text)
                
                Text("KM/H")
                    .font(.spaceMediumFont(size: 20))
                    .foregroundStyle(.acidGreen)
                
            }
        }
        .frame(width: 250, height: 250)
                .padding()
    }
    
    
    private func calculateTrim() -> CGFloat {
            let progress = speed / maxDisplaySpeed
            
            return CGFloat(0.1 + (progress * 0.8))
        }
}

#Preview {
    CurrentSpeedView(speed: 120.0)
}
