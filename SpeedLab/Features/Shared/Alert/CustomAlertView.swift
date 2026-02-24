//
//  CustomAlertView.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 30.01.2026.
//

import SwiftUI

struct CustomAlertView: View {
    let title:String
    let message:String
    let primaryTextButton:String
    let onPrimaryAction:()->Void
    var onCancel: (() -> Void)? = nil
    
    var body: some View {
        ZStack{
            Color.deepCharcoal.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onCancel?   () }
            
            VStack(spacing:20){
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.acidGreen)
                VStack(spacing:8){
                    Text(title)
                        .font(.spaceBoldFont(size: 24))
                        .foregroundStyle(.text)
                    
                    Text(message)
                        .font(.spaceRegularFont(size: 18))
                        .foregroundStyle(.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                HStack(spacing: 12){
                    if let cancelAction = onCancel {
                                            Button(action: cancelAction) {
                                                Text("Cancel")
                                                    .font(.spaceMediumFont(size: 16))
                                                    .foregroundStyle(.text)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 12)
                                                    .background(.text.opacity(0.1))
                                                    .cornerRadius(12)
                                            }
                                        }
                    
                    
                    Button(action:onPrimaryAction) {
                        Text(primaryTextButton)
                            .font(.spaceMediumFont(size: 16))
                            .foregroundStyle(.text)
                            .frame(maxWidth:.infinity)
                            .padding(.vertical, 12)
                            .background(.text.opacity(0.1))
                            .cornerRadius(12)
                        
                    
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 24)
                .background(Color.deepCharcoal)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 40)
        }
        
    }
}

#Preview {
    CustomAlertView(title: "Error", message:"Testing alert view message", primaryTextButton: "Okey", onPrimaryAction: {
        print("Primary Button Tapped!")
    }, onCancel: nil)
}
