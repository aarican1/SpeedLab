//
//  DriveView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 29.01.2026.
//

import SwiftUI

struct DriveView: View {
    @EnvironmentObject var router: AppRouter
    @ObservedObject var viewModel : DriveViewModel
    @Environment(\.dismiss) var dismiss
 
    
    var body: some View {
        ZStack {
            VStack(spacing:12){
                CurrentSpeedView(speed: viewModel.speed )
                PerformanceMetricsGridView(viewModel: viewModel)
                
                HStack{
                    Button{
                        if viewModel.isPaused {
                            viewModel.resumeTracking()
                        }
                        else{
                            viewModel.pauseTracikng()
                        }
                    } label: {
                        HStack{
                            Image(systemName: "pause.fill")
                                .foregroundColor(.electricBlue)
                            Text("Pause")
                                .font(.spaceBoldFont(size: 24))
                                .foregroundStyle(.electricBlue)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(.electricBlue, lineWidth: 1)
                        )
                        .foregroundStyle(.electricBlue)
                    }
                    
                    Button{
                        viewModel.stopTracking()
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
            if viewModel.showSuccessAlert{
                Color.deepCharcoal.opacity(0.5).ignoresSafeArea()
                CustomAlertView(title:"Drive Saved" ,
                                message: "Your drive datas have been saved in history",
                                primaryTextButton:"Okey") {
                        router.popToRoot()
                    
                    let count = UserDefaults.standard.integer(forKey: "completedDriveCount")
                                        
                    if count > 2 { 
                                        ReviewManager.requestReview()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        router.switchTab(to: .history)
                        viewModel.clearViewModel()
                        }
                    } onCancel: {
                        viewModel.clearViewModel()
                        router.popToRoot()
                    }
                }
            }
            .onChange(of: viewModel.shouldExitImmediately) { shouldExit in
                if shouldExit {
                    router.popToRoot()
                    viewModel.clearViewModel()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement:.navigationBarLeading) {
                    Button{
                        viewModel.stopTracking(isSlient: true)
                        router.popToRoot()
                        viewModel.clearViewModel()
                
                    } label: {
                        HStack(spacing:4){
                            Image(systemName: "chevron.left")
                            Text("Back")
                                .font(.spaceRegularFont(size: 14))
                        }
                        .foregroundStyle(.electricBlue)
                    }
                }
            }
            .onDisappear{
                if viewModel.isDriveViewActive {
                viewModel.stopTracking()
                viewModel.clearViewModel()
            }
            }
        }
        
    }


#Preview {
    DriveView(viewModel: DriveViewModel(repository: PerformanceRepository()))
}
