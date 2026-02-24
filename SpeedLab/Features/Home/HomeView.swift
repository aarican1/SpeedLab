//
//  HomeView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 26.01.2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router : AppRouter
    @ObservedObject var viewModel : DriveViewModel
    @Environment(\.openURL) var openURL
    var body: some View {
    
            ZStack {
                Color(.deepCharcoal)
                    .ignoresSafeArea()
                VStack(spacing:16){
                    VStack {
                        Text("Welcome to")
                            .font(.spaceLightFont(size: 16))
                            .foregroundStyle(.gray)
                        Text("Speed Lab")
                            .font(.spaceBoldFont(size: 20))
                            .foregroundStyle(.text)
                    }
                    .padding(.vertical, 32)
                    WarningView()
                        
                    StartSessionView()
                        .onTapGesture {
                        
                           let isSucces =  viewModel.toggleTracking()
                            if isSucces{
                                router.navigate(to: .drive)
                            }
                        }
                    HStack {
                        Image(systemName: "info.windshield")
                            .foregroundStyle(.text)
                        Text("About")
                            .font(.spaceLightFont(size: 18))
                    }
                    .onTapGesture {
                        if let url = URL(string: PathConstants.privacyURLPath){
                            openURL(url)
                        }
                    }
                    .padding(.top, 12)
                    Spacer()
                    
                   
                    
                  
                    
                   

                    }
                if viewModel.showErrorAlert {
                    if let error = viewModel.activeError {
                        CustomAlertView(title:error.title , message: error.message, primaryTextButton:error.actionTitle) {
                            switch error.actionType {
                                        case .openSettings:
                                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                                UIApplication.shared.open(url)
                                            }
                                        case .requestPermission:
                                      let  isSucces =  viewModel.toggleTracking()
                                if isSucces {
                                    router.navigate(to: .drive)
                                }
                                        case .dismiss:
                                            viewModel.showErrorAlert = false
                                        }
                            viewModel.showErrorAlert = false
                        }
                    }
                }       
            }
    }
    
}

#Preview {
    HomeView(viewModel: DriveViewModel(repository: PerformanceRepository()))
        .environmentObject(AppRouter())
}
