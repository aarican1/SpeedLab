//
//  TabRoute.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 2.02.2026.
//

import Foundation

enum TabRoute:String , CaseIterable {
    case home  = "gauge.with.needle.fill"
    case history = "chart.bar.xaxis"
}

enum NavRoute:Hashable{
     case drive
}
