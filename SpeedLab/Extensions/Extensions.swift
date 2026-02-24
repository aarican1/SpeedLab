//
//  Extensions.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 28.01.2026.
//
import SwiftUI



extension Font {
    
    static func spaceRegularFont(size:CGFloat) ->Font {
        return .custom("SpaceGrotesk-Regular", size: size)
    }
    
    static func spaceLightFont(size:CGFloat) ->Font {
        return .custom("SpaceGrotesk-Light", size:size)
    }
    
    static func spaceMediumFont(size:CGFloat) ->Font {
        return .custom("SpaceGrotesk-Medium", size: size)
    }
    
    static func spaceSemiBoldFont(size:CGFloat) ->Font{
        return .custom("SpaceGrotesk-SemiBold", size: size)
    }
    
    static func spaceBoldFont(size:CGFloat) ->Font{
        return .custom("SpaceGrotesk-Bold", size: size)
    }
}
