//
//  MetricMiniItemView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 29.01.2026.
//

import SwiftUI

struct MetricMiniItemView: View {
    let title: LocalizedStringKey
    let icon : String
    let value: String
    let unit:  String
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            HStack(alignment:.top) {
                Image(systemName: icon)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.white)
                Text(title)
                    .font(.spaceRegularFont(size: 16))
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
            HStack {
                Text(value)
                    .font(.spaceSemiBoldFont(size: 28))
                    .foregroundStyle(.white)
                Text(unit)
                    .font(.spaceSemiBoldFont(size: 18))
                    .foregroundStyle(.gray)
            }
            
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: 92,alignment: .leading )
        .background(.glassCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
        )
      
       
        
    }
}

#Preview {
    MetricMiniItemView(title: "Distance",icon: "exclamationmark.brakesignal",  value: "12.4 km", unit: "km")
}
