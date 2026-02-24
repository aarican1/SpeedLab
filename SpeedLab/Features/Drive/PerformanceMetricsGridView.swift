//
//  PerformanceMetricsListView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 29.01.2026.
//

import SwiftUI

struct PerformanceMetricsListView: View {
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    
    var body: some View {
        ScrollView {
            Text("Performance Tracking")
                .font(.spaceBoldFont(size: 24))
                .foregroundStyle(.gray)
                
            LazyVGrid(columns: columns) {
                MetricMiniItemView(title: "0 - 100 acculeration", value: "10:02 second")
                MetricMiniItemView(title: "0 - 200 acculeration", value: "23:50 second")
                MetricMiniItemView(title: "100 - 0 braking", value: "44 meter")
                
                
            }
        }
    }
}

#Preview {
    PerformanceMetricsListView()
}
