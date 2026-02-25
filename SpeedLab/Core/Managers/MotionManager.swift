//
//  MotionManager.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 29.01.2026.
//

import Foundation
import CoreMotion
import Combine
import simd


final class MotionManager: NSObject, ObservableObject {
    
    private let motionManager = CMMotionManager()
    
    @Published var acceleration: CMAcceleration = .init()
    @Published var totalGForce: Double = 0.0
    @Published var isAvaliable: Bool = false
    @Published var accessDenied: Bool = false
    
    /// Forward (longitudinal) acceleration in m/s² — gravity-free, device-orientation-aware
    @Published var forwardAcceleration: Double = 0.0

    
    /// Timestamp when sustained forward movement was first detected
    @Published var movementDetectedAt: Date?
    
    //Kalman Filters Speed Value
    @Published var kalmanSpeed: Double = 0.0
    
    
    /// Consecutive positive-acceleration sample count for debouncing
    private var sustainedAccelCount: Int = 0
    
    /// Threshold: minimum forward accel (m/s²) to count as "moving"
    private static let movementThreshold: Double = 0.15
    /// Number of consecutive samples above threshold needed (~60 ms at 100 Hz)
    private static let sustainedSampleCount: Int = 6
    
    private var lastUpdateTime: Date?
    
    private var forwardDirection: simd_double3?
    private var kalmanFilter = SpeedKalmanFilter()
    
    override init() {
        super.init()
        self.isAvaliable = motionManager.isDeviceMotionAvailable
    }
    
    
    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
            
        motionManager.deviceMotionUpdateInterval = 0.01  // 100 Hz
        
        // Reset state
        movementDetectedAt = nil
        sustainedAccelCount = 0
        lastUpdateTime = nil
        forwardAcceleration = 0.0
        forwardDirection = nil
        kalmanFilter.reset(to: 0.0)
        kalmanSpeed = 0.0
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            if let error = error {
                if (error as NSError).code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
                    self?.accessDenied = true
                }
                return
            }
            
            guard let self = self, let motion = motion else { return }
            
            self.acceleration = motion.userAcceleration
            
            // --- Total G-Force (existing) ---
            let gx = motion.userAcceleration.x + motion.gravity.x
            let gy = motion.userAcceleration.y + motion.gravity.y
            let gz = motion.userAcceleration.z + motion.gravity.z
            self.totalGForce = sqrt(gx * gx + gy * gy + gz * gz)
            
            let userAcc = simd_double3(motion.userAcceleration.x,
                                       motion.userAcceleration.y,
                                       motion.userAcceleration.z)
            
            let gravity = simd_double3(motion.gravity.x,
                                       motion.gravity.y,
                                       motion.gravity.z)
            
            let gNorm = simd_normalize(gravity)
            
            guard simd_length(gravity) > 0.01 else { return }
            
            let dotProduct = simd_dot(userAcc, gNorm)
            let horizontalAcc = userAcc - (gNorm * dotProduct)
            
            let horizontalMag = simd_length(horizontalAcc)
            
            
            if self.forwardDirection == nil {
                if horizontalMag > MotionManager.movementThreshold {
                    self.sustainedAccelCount += 1
                    if self.sustainedAccelCount >= MotionManager.sustainedSampleCount {
                        self.forwardDirection = simd_normalize(horizontalAcc)
                        let backtrackInterval = Double(MotionManager.sustainedSampleCount) * 0.01
                        self.movementDetectedAt = Date().addingTimeInterval(-backtrackInterval)
                    }
                } else {
                    self.sustainedAccelCount = 0
                }
                
                self.forwardAcceleration = 0.0
                return
            }
            
            if let forwardDir = self.forwardDirection {
                let forwardAccG = simd_dot(horizontalAcc, forwardDir)
                let forwardAcc = forwardAccG * 9.81
                
                self.forwardAcceleration = forwardAcc
                
                let now  = Date()
                if let lastTime = self.lastUpdateTime {
                    let dt = now.timeIntervalSince(lastTime)
                    
                    if dt > 0 && dt < 0.1 {
                        let deltaV = forwardAcc * dt * 3.6
                        self.kalmanFilter.predict(deltaV: deltaV)
                        if self.kalmanFilter.speed < 0 { self.kalmanFilter.speed = 0 }
                        
                        self.kalmanSpeed = self.kalmanFilter.speed
                    }
                }
                self.lastUpdateTime = now
            }
            
        }
    }
    
    func updateWithGps(speed:Double){
        kalmanFilter.update(gpsSpeed: speed)
        self.kalmanSpeed = kalmanFilter.speed
    }
    
    /// Reset movement detection for a new measurement
    func resetMovementDetection() {
        movementDetectedAt = nil
        sustainedAccelCount = 0
        lastUpdateTime = nil
        forwardDirection = nil
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
        
        self.acceleration = .init()
        self.totalGForce = 0.0
        self.forwardAcceleration = 0.0
        self.movementDetectedAt = nil
        self.sustainedAccelCount = 0
        self.lastUpdateTime = nil
        self.forwardDirection = nil
        self.kalmanSpeed = 0.0
        self.kalmanFilter.reset(to: 0.0)
    }
}
