//
//  StartSessionView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 26.01.2026.
//

import SwiftUI

struct StartSessionView: View {
    var body: some View {
        ZStack{
            Circle()
                .fill()
                .frame(width: 300, height: 300)
                .foregroundStyle(.electricBlue)
                .shadow(color:.electricBlue,radius: 20)
            Circle()
                .fill()
                .frame(width: 290, height: 290)
                .foregroundStyle(.deepCharcoal)
                .shadow(radius: 10)
            
            VStack {
                Image(systemName: "play.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.text)
                    .padding()
                
                Text("Start Session")
                    .font(.spaceRegularFont(size: 28))
                    .foregroundStyle(.text)
            }
                
        }
    }
}

#Preview {
    StartSessionView()
}
