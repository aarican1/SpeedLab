//
//  NoHistorySessionView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 6.02.2026.
//

import SwiftUI

struct NoHistorySessionView: View {
    var body: some View {
        VStack{
            Image(systemName: "car.rear.tilt.road.lanes.curved.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48,height: 48)
                .foregroundStyle(.text)
            Text("No driving has been recorded yet.")
                .font(.spaceBoldFont(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(.text)
        }
    }
}

#Preview {
    NoHistorySessionView()
}
