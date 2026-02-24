//
//  DriveView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 29.01.2026.
//

import SwiftUI

struct DriveView: View {
    var body: some View {
        VStack(spacing:16){
            CurrentSpeedView(speed: 121)
            HStack{
                MetricMiniItemView(title: "Distance", icon: "road.lanes.curved.right", value: "12.4 km")
                Spacer()
                MetricMiniItemView(title: "Time",icon:"timer", value: "2:44 dk")
            }
            Text("Performance Tracking")
                .font(.spaceBoldFont(size: 24))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading) 
            PerformanceMetricsGridView()
            
            HStack{
                Button{
                    print("pause")
                } label: {
                    HStack{
                        Image(systemName: "pause.fill")
                            .foregroundColor(.red)
                        Text("Pause")
                            .font(.spaceBoldFont(size: 24))
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.red, lineWidth: 1)
                    )
                    .foregroundColor(.red)
                }
                
                Button{
                    print("stop")
                } label: {
                    HStack{
                        Image(systemName: "stop.fill")
                            .foregroundColor(.red)
                        Text("Stop")
                            .font(.spaceBoldFont(size: 24))
                        
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.red, lineWidth: 1)
                    )
                    .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    DriveView()
}
