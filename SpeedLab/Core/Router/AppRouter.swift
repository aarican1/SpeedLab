//
//  AppRouter.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 2.02.2026.
//

import SwiftUI
import Combine

final class AppRouter: ObservableObject {
    @Published var selectedTab: TabRoute = .home
    @Published var currentRoute : NavRoute?  = nil
    
    func switchTab(to tab: TabRoute) {
        withAnimation(.spring(response:0.3,dampingFraction:0.7)){
            self.selectedTab = tab
        }
    }
    
    func navigate(to route: NavRoute) {
        self.currentRoute = route
    }
    
    func popToRoot() {
        self.currentRoute = nil
    }
}
