//
//  ReviewManager.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 6.02.2026.
//

import Foundation
import SwiftUI
import StoreKit

final class ReviewManager {
    static func requestReview() {
        if let scene  = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
