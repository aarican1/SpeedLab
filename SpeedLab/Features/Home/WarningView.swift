//
//  WarningView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 31.01.2026.
//

import SwiftUI

struct WarningView: View {
    var body: some View {
        VStack (alignment: .leading, spacing: 4){
            Text("⚠️ IMPORTANT WARNING & DISCLAIMER")
                .font(.spaceSemiBoldFont(size: 14))
                .foregroundStyle(.text)
            
            Text("This app is designed to measure performance metrics like 0-100, 0-200, 100-0, and top speed; however, all measurements rely on GPS and device sensors, which may contain margins of error due to environmental factors. These results are not a substitute for professional equipment. All tests must be conducted strictly on closed tracks or private roads following safe riding principles. The developer shall not be held liable for any accidents, material or moral damages, or legal violations resulting from the use of this app; all risks are assumed by the user")
                .font(.spaceLightFont(size: 12))
                .foregroundStyle(.text)
            
            
        }
        .padding(.horizontal,24)
        
    }
}

#Preview {
    WarningView()
}
