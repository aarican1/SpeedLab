//
//  PerformanceMetricsGridView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 29.01.2026.
//

import SwiftUI

struct PerformanceMetricsGridView: View {
    @ObservedObject var viewModel: DriveViewModel
    
   private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            
            
            MetricMiniItemView(title: "Distance", icon: "road.lanes.curved.right", value: viewModel.distance, unit: "km")
            
            MetricMiniItemView(title: "Time",icon:"timer", value: viewModel.sessionTime, unit: "")
            
            MetricMiniItemView(title: "Max-Speed",icon:"timer", value: "\(viewModel.maxSpeed)",  unit: "km/h")
            
            MetricMiniItemView(title: "0 - 100 Time", icon: "speedometer", value: viewModel.zeroToHundred, unit: "s")
            
            MetricMiniItemView(title: "0 - 200 Time", icon: "bolt.fill", value: viewModel.zeroToTwoHundred,  unit:"s")
            
            MetricMiniItemView(title: "100 - 0 Brake", icon: "exclamationmark.brakesignal", value: viewModel.brakingDistanceHundredToZero,  unit:"m")
            
            MetricMiniItemView(title: "G-Force", icon: "move.3d", value: viewModel.gForce, unit:"g")
          
        }
    }
}

#Preview {
    PerformanceMetricsGridView(viewModel: DriveViewModel(repository: PerformanceRepository()))
}
