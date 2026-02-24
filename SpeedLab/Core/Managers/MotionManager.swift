//
//  MotionManager.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 29.01.2026.
//

import Foundation
import CoreMotion
import Combine


final class MotionManager: NSObject, ObservableObject {
    
    private let motionManager = CMMotionManager()
    
    @Published var acceleration: CMAcceleration = .init()
    @Published var totalGForce: Double = 0.0
    @Published var isAvaliable: Bool = false
    @Published var accessDenied: Bool = false
    
    /// Forward (longitudinal) acceleration in m/s² — gravity-free, device-orientation-aware
    @Published var forwardAcceleration: Double = 0.0
    
    /// Accumulated velocity from accelerometer integration (km/h)
    @Published var integratedSpeed: Double = 0.0
    
    /// Timestamp when sustained forward movement was first detected
    @Published var movementDetectedAt: Date?
    
    /// Consecutive positive-acceleration sample count for debouncing
    private var sustainedAccelCount: Int = 0
    
    /// Threshold: minimum forward accel (m/s²) to count as "moving"
    private static let movementThreshold: Double = 0.15
    /// Number of consecutive samples above threshold needed (~60 ms at 100 Hz)
    private static let sustainedSampleCount: Int = 6
    
    private var lastUpdateTime: Date?
    
    override init() {
        super.init()
        self.isAvaliable = motionManager.isDeviceMotionAvailable
    }
    
    
    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.01  // 100 Hz
        
        // Reset state
        integratedSpeed = 0.0
        movementDetectedAt = nil
        sustainedAccelCount = 0
        lastUpdateTime = nil
        forwardAcceleration = 0.0
        
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
            
            // --- Forward acceleration (gravity-subtracted userAcceleration) ---
            // Project userAcceleration onto gravity vector to get longitudinal component
            // This works in any device orientation
            let gravMag = sqrt(
                motion.gravity.x * motion.gravity.x +
                motion.gravity.y * motion.gravity.y +
                motion.gravity.z * motion.gravity.z
            )
            
            guard gravMag > 0.01 else { return }
            
            // User acceleration magnitude along the horizontal plane
            // For a phone lying flat or in a holder, forward accel ≈ userAcceleration projected
            // onto the horizontal plane. We use the total userAcceleration magnitude as a
            // simplified approach — works well for car mounting scenarios.
            let userAccMag = sqrt(
                motion.userAcceleration.x * motion.userAcceleration.x +
                motion.userAcceleration.y * motion.userAcceleration.y +
                motion.userAcceleration.z * motion.userAcceleration.z
            )
            
            // Determine sign: dot product of userAcceleration and gravity
            // Positive dot = decelerating (falling toward gravity), Negative dot = accelerating (pushed away)
            // For a car: forward acceleration pushes you back into seat → specific sign pattern
            // We use absolute magnitude with sign from the dominant horizontal axis
            let forwardAcc = userAccMag * 9.81  // Convert g to m/s²
            self.forwardAcceleration = forwardAcc
            
            // --- Velocity integration ---
            let now = Date()
            if let lastTime = self.lastUpdateTime {
                let dt = now.timeIntervalSince(lastTime)
                if dt > 0 && dt < 0.1 { // Sanity check: skip if dt is unreasonable
                    let deltaV = forwardAcc * dt * 3.6  // m/s² → km/h
                    self.integratedSpeed += deltaV
                    
                    // Clamp to prevent runaway drift
                    if self.integratedSpeed < 0 { self.integratedSpeed = 0 }
                }
            }
            self.lastUpdateTime = now
            
            // --- Movement detection (debounced) ---
            if self.movementDetectedAt == nil {
                if forwardAcc > MotionManager.movementThreshold {
                    self.sustainedAccelCount += 1
                    if self.sustainedAccelCount >= MotionManager.sustainedSampleCount {
                        // Sustained acceleration detected — timestamp the start
                        // Backtrack to when acceleration first crossed threshold
                        let backtrackInterval = Double(MotionManager.sustainedSampleCount) * 0.01
                        self.movementDetectedAt = now.addingTimeInterval(-backtrackInterval)
                    }
                } else {
                    self.sustainedAccelCount = 0
                }
            }
        }
    }
    
    /// Reset accelerometer integration (call when GPS confirms a reliable speed)
    func resetIntegration(toSpeed speed: Double) {
        integratedSpeed = speed
    }
    
    /// Reset movement detection for a new measurement
    func resetMovementDetection() {
        movementDetectedAt = nil
        sustainedAccelCount = 0
        integratedSpeed = 0.0
        lastUpdateTime = nil
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
        
        self.acceleration = .init()
        self.totalGForce = 0.0
        self.forwardAcceleration = 0.0
        self.integratedSpeed = 0.0
        self.movementDetectedAt = nil
        self.sustainedAccelCount = 0
        self.lastUpdateTime = nil
    }
}
