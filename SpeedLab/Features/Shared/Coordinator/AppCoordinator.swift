//
//  AppCoordinator.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 2.02.2026.
//

import SwiftUI

struct AppCoordinator: View {
    @StateObject private var router = AppRouter()
    @StateObject private var driveViewModel = DriveViewModel(repository: PerformanceRepository())
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom){
                
                TabView(selection: $router.selectedTab) {
                    HomeView(viewModel: driveViewModel)
                            .tag(TabRoute.home)
                            .background(
                                NavigationLink(
                                 tag: NavRoute.drive,
                                   selection: $router.currentRoute,
                                   destination: {
                                    DriveView(viewModel: driveViewModel)
                                           .environmentObject(router)
    
                                    }) { EmptyView() })
                
                    
                    HistoryView()
                        .tag(TabRoute.history)
                }
                .onAppear {
                    UITabBar.appearance().isHidden = true
                }
                if router.currentRoute == nil {
                    CustomTabBarView()
                        .environmentObject(router)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            
            }
            .navigationBarHidden(true)
        }
       
        .environmentObject(router)
    }
}

#Preview {
    AppCoordinator()
}
