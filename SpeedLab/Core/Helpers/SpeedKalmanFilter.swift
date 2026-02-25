            //
            //  SpeedKalmanFilters.swift
            //  SpeedLab
            //
            //  Created by Abdurrahman Arıcan on 25.02.2026.
            //

            import Foundation

            struct SpeedKalmanFilter {
                var speed : Double = 0.0
                
                private var p: Double = 1.0
                
                private let q: Double = 0.05
                
                private let r: Double = 3.0
                
                mutating func predict(deltaV :Double) {
                    speed += deltaV
                    
                    p += q
                }
                
                mutating func update(gpsSpeed: Double){
                    let k = p / (p + r)
                    
                    speed = speed + k * (gpsSpeed - speed)
                    
                    p = (1.0 - k) * p
                }
                
                mutating func reset(to speed: Double = 0.0) {
                    self.speed = speed
                    self.p = 1.0
                }
                    
            }
