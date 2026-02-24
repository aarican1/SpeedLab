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
            ZStack{
                HomeView(viewModel: driveViewModel)
                    .environmentObject(router)
                
                NavigationLink(
                        destination: DriveView(viewModel: driveViewModel).environmentObject(router),
                                    tag: AppRoute.drive,
                                    selection: $router.currentRoute
                                ) { EmptyView() }
                
                NavigationLink(
                                    destination: HistoryView().environmentObject(router),
                                    tag: AppRoute.history,
                                    selection: $router.currentRoute
                                ) { EmptyView() }
            }
        }
    }
}

#Preview {
    AppCoordinator()
}
