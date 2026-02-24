//
//  CustomTabBarView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 2.02.2026.
//

import SwiftUI

struct CustomTabBarView: View {
    @EnvironmentObject var router: AppRouter
    @Namespace var animationNamespace
    
    var body: some View {
        HStack(spacing:0){
            ForEach(TabRoute.allCases, id: \.self){ tab in
                Button{
                    router.switchTab(to: tab)
                } label: {
                    Image(systemName: tab.rawValue)
                        .font(.system(size: 20))
                        .frame(maxWidth:.infinity)
                        .frame(height: 50)
                        .contentShape(Rectangle())
                        .foregroundStyle(router.selectedTab == tab ? .deepCharcoal : .electricBlue)
                        .background{
                            if router.selectedTab == tab {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.acidGreen)
                                    .matchedGeometryEffect(id: "activeTabIndicator", in: animationNamespace)
                                    .shadow(color:.electricBlue.opacity(0.5), radius: 8, y: 0)
                            }
                        }
                }
            }
        }
        .padding(6)
        .background(Color.glassCard)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal , 24)
        .shadow(color:.glassCard.opacity(0.3), radius:10, y:5)
    }
}

#Preview {
    CustomTabBarView()
}
