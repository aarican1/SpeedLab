//
//  PerformanceRepository.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 29.01.2026.
//

import Foundation
import CoreLocation
import Combine

class PerformanceRepository: ObservableObject{
    @Published var speed                        : Double = 0.0
    @Published var maxSpeed                     : Double = 0.0
    @Published var distance                     : Double = 0.0
    @Published var sessionTime                  : TimeInterval  = 0.0
    @Published var zeroToHundred                : Double = 0.0
    @Published var zeroToTwoHundred             : Double = 0.0
    @Published var brakingDistanceHundredToZero : Double = 0.0
    @Published var gForce                       : Double = 0.0
    @Published var bestZeroToHundred: Double = Double.infinity
    @Published var bestZeroToTwoHundred : Double = Double.infinity
    
    @Published var isPaused : Bool = false
    
    @Published var locationAuthStatus: CLAuthorizationStatus = .notDetermined
    
    let saveOperationCompleted = PassthroughSubject<Bool,Never>()
    
    private let locationManager = LocationManager()
    private let motionManager = MotionManager()
    private var cancellables = Set<AnyCancellable>()
    
    private var startTime: Date?
    private var startLocation : CLLocation?
    private var lastLocation: CLLocation?
    private var zeroToHundredStartTime: Date?
    private var zeroToTwoHundredStartTime: Date?
    private var brakingStartLocation: CLLocation?
    
    private var lastProcessedSpeed: Double?
    private var lastProcessedTime: Date?
    
    /// Flag: accelerometer already triggered start for this measurement cycle
    private var accelStartTriggered: Bool = false
    
    
    init(){
        setupBindings()
    }
    
    
    func checkManagersAvaliability() -> PerformanceError? {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            
            locationManager.requestLocationPermission()
            return nil
        case .restricted:
            return .lDeniedOrRestricted
        case .denied:
            return .lDeniedOrRestricted
            
        case .authorizedAlways ,.authorizedWhenInUse, .authorized, nil ,.some(_) :
            break
        }
        if motionManager.isAvaliable == false {
            return .mSensorNotAvaliability
        }
        
        return nil
    }
    
    
    private func setupBindings(){
        
        locationManager.$authorizationStatus
            .map{ $0 ?? .notDetermined}
            .assign(to: &$locationAuthStatus)
        
        // --- G-Force tracking (unchanged) ---
        motionManager.$totalGForce
            .receive(on: DispatchQueue.main)
            .filter { [weak self] _ in !(self?.isPaused ?? false) }
            .sink { [weak self] value in
                if  self?.gForce ?? 0.0 < value && value > 0.1 {
                    self?.gForce = value
                }
            }
            .store(in: &cancellables)
        
        // --- Accelerometer-based start detection (100 Hz) ---
        motionManager.$movementDetectedAt
            .compactMap { $0 }
            .filter { [weak self] _ in
                guard let self = self else { return false }
                return !self.isPaused && !self.accelStartTriggered
            }
            .sink { [weak self] detectedAt in
                guard let self = self else { return }
                // Accelerometer detected sustained forward movement
                // Set this as start time — GPS will confirm/refine later
                if self.zeroToHundredStartTime == nil {
                    self.zeroToHundredStartTime = detectedAt
                    self.zeroToTwoHundredStartTime = detectedAt
                    self.accelStartTriggered = true
                }
            }
            .store(in: &cancellables)
        
        // --- Braking detection via accelerometer ---
        motionManager.$forwardAcceleration
            .filter { [weak self] _ in !(self?.isPaused ?? false) }
            .sink { [weak self] acc in
                guard let self = self else { return }
                if acc > 0.5 * 9.81 && (97...103).contains(self.speed) {
                    self.brakingStartLocation = self.lastLocation
                }
            }
            .store(in: &cancellables)
        
        motionManager.$kalmanSpeed
            .receive(on:DispatchQueue.main)
            .filter{ [weak self] _ in !(self?.isPaused ?? false) }
            .sink { [weak self] currentSpeed in
                guard let self = self else { return }
                self.speed = currentSpeed
                
                let now = Date()
                if let start = self.zeroToHundredStartTime, currentSpeed >= 100 {
                    let duration = now.timeIntervalSince(start)
                    self.zeroToHundred = duration
                    
                    if duration < self.bestZeroToHundred{
                        self.bestZeroToHundred = duration
                    }
                    self.zeroToHundredStartTime = nil
                }
                
                if let start200 = self.zeroToTwoHundredStartTime, currentSpeed >= 200.0 {
                    let duration = now.timeIntervalSince(start200)
                    self.zeroToTwoHundred = duration
                    
                    if duration < self.bestZeroToTwoHundred {
                        self.bestZeroToTwoHundred = duration
                    }
                    self.zeroToTwoHundredStartTime = nil
                }
            }
            .store(in: &cancellables)
        
        // --- GPS location updates ---
        locationManager.$location
            .compactMap { $0 }
            .filter { [weak self] _ in !(self?.isPaused ?? false) }
            .sink { [weak self] newLocation in
                guard let self = self else { return }
                
                let currentSpeedKmH = max(0, newLocation.speed * 3.6)
                
    
                if currentSpeedKmH > self.maxSpeed { self.maxSpeed = currentSpeedKmH }
                
                if let lastLoc = self.lastLocation {
                    if currentSpeedKmH > 2.0 {
                        let traveled = newLocation.distance(from: lastLoc)
                        self.distance += (traveled / 1000)
                    }
                }
                
                self.lastLocation = newLocation
                self.startLocation = newLocation
                
                // Sync accelerometer integration with GPS ground truth
                self.motionManager.updateWithGps(speed: currentSpeedKmH)
                
                self.processPerformanceMetrics(speed: currentSpeedKmH, location: newLocation)
            }
            .store(in: &cancellables)
        
        Timer.publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .filter { [weak self] _ in !(self?.isPaused ?? false) }
                .sink { [weak self] _ in
                    guard let self = self, self.startTime != nil else { return }
                    self.sessionTime += 1.0
                }
                .store(in: &cancellables)
    }
    
    
    
    private func processPerformanceMetrics(speed: Double, location: CLLocation) {
            guard !isPaused else { return }
            let currentTime = location.timestamp
            
            // --- GPS-based fallback start trigger (İvmeölçer kaçırırsa diye yedek) ---
            if speed >= 2.0 && zeroToHundredStartTime == nil {
                zeroToHundredStartTime = currentTime
                zeroToTwoHundredStartTime = currentTime
            }
            
            // --- Fren Mesafesi ---
            if speed <= 2.0, let startLoc = brakingStartLocation {
                self.brakingDistanceHundredToZero = location.distance(from: startLoc)
                brakingStartLocation = nil
            }
            
            self.lastProcessedSpeed = speed
            self.lastProcessedTime = currentTime
    }
    
    
    func pauseTracking() {
        isPaused = true
        zeroToHundredStartTime = nil
        zeroToTwoHundredStartTime = nil
        accelStartTriggered = false
        motionManager.resetMovementDetection()
    }

    func resumeTracking() {
        self.lastLocation = nil
        self.accelStartTriggered = false
        motionManager.resetMovementDetection()
        isPaused = false
    }
    
    
    func start(){
        locationManager.requestLocationPermission()
        locationManager.startUpdatingLocation()
        motionManager.start()
        
        if startTime == nil {
                startTime = Date()
            }
        isPaused = false
    }
    
    func stopTracking(){
        
        if distance > 0.1 && speed > 5 {
            
            CoreDataManager.shared.saveSession(maxSpeed: maxSpeed, distance: distance, duration: sessionTime, zeroToHundred: bestZeroToHundred, zeroToTwoHundred: bestZeroToTwoHundred, brakingDistance: brakingDistanceHundredToZero, maxGForce: gForce)
            
            saveOperationCompleted.send(true)
        }
        else{
            saveOperationCompleted.send(false)
        }

        
        locationManager.stopUpdatingLocation()
        motionManager.stop()
        
        startTime = nil
        zeroToHundredStartTime = nil
        zeroToTwoHundredStartTime = nil
        brakingStartLocation = nil
        lastLocation = nil
        lastProcessedSpeed = nil
        lastProcessedTime = nil
        accelStartTriggered = false
        
        speed                         = 0.0
        maxSpeed                      = 0.0
        distance                      = 0.0
        sessionTime                   = 0.0
        zeroToHundred                 = 0.0
        zeroToTwoHundred              = 0.0
        brakingDistanceHundredToZero  = 0.0
        gForce                        = 0.0
    }
    

    enum PerformanceError: Error {
            case lDeniedOrRestricted
            case lNotDetermined
            case mSensorNotAvaliability
            
            enum ActionType {
                case openSettings
                case requestPermission
                case dismiss
            }

            var title: String {
                switch self {
                case .lDeniedOrRestricted:
                    // String Catalog için "Key" yerine doğrudan İngilizce metni yazıyoruz.
                    // comment: parametresini çeviri yapacak kişiye not olarak ekliyoruz.
                    return String(localized: "Location Access Denied", comment: "Title when location is denied")
                    
                case .lNotDetermined:
                    return String(localized: "Location Required", comment: "Title when location is not determined")
                    
                case .mSensorNotAvaliability:
                    return String(localized: "Sensor Error", comment: "Title for sensor error")
                }
            }
            
            var message: String {
                switch self {
                case .lDeniedOrRestricted:
                    return String(localized: "Speed measurement requires location access. Please enable it in Settings.", comment: "Error message for denied location")
                    
                case .lNotDetermined:
                    return String(localized: "We need your location to track performance metrics like speed and distance.", comment: "Error message for undetermined location")
                    
                case .mSensorNotAvaliability:
                    return String(localized: "Motion sensors are not available on this device. G-Force tracking is disabled.", comment: "Error message for sensor failure")
                }
            }
            
            var actionTitle: String {
                switch self {
                case .lDeniedOrRestricted:
                    return String(localized: "Go to Settings", comment: "Button title")
                case .lNotDetermined:
                    return String(localized: "Allow Access", comment: "Button title")
                case .mSensorNotAvaliability:
                    return String(localized: "OK", comment: "Button title")
                }
            }
            
            // ... actionType kısmı aynı kalabilir ...
            var actionType: ActionType {
                switch self {
                case .lDeniedOrRestricted: return .openSettings
                case .lNotDetermined: return .requestPermission
                case .mSensorNotAvaliability: return .dismiss
                }
            }
        }
    
}


