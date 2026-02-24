//
//  HomeView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 26.01.2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        
        ZStack {
            Color(.deepCharcoal)
                .ignoresSafeArea()
            VStack{
                VStack {
                    Text("Welcome to")
                        .font(.spaceLightFont(size: 16))
                        .foregroundStyle(.gray)
                    Text("Speed Lab")
                        .font(.spaceBoldFont(size: 20))
                        .foregroundStyle(.text)
                }
                .padding(.vertical, 32)
                
                Spacer()
                StartSessionView()
                    .onTapGesture {
                        print("OnTap")
                    }
                Spacer()
                
                HStack {
                    Image(systemName: "info.windshield")
                        .foregroundStyle(.text)
                    Text("About")
                        .font(.spaceLightFont(size: 18))
                }
                .onTapGesture {
                    print("Hakkında Tapped")
                }
                
            }
            
            
           
        }
       
    }
    
}

#Preview {
    HomeView()
}
