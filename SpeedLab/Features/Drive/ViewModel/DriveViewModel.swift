//
//  DriveViewModel.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 29.01.2026.
//

import Foundation
import Combine

final class DriveViewModel: ObservableObject {
    @Published var speed                        : Double = 0.0
    @Published var maxSpeed                     : String = "0.0 km/h"
    @Published var distance                     : String = "0.0 km"
    @Published var sessionTime                  : String  = "0:00 s"
    @Published var zeroToHundred                : String = "0:00 s"
    @Published var zeroToTwoHundred             : String = "0.00 s"
    @Published var brakingDistanceHundredToZero : String = "0.00 s"
    @Published var gForce                       : String = "0.0 g"
    @Published var isDriveViewActive            : Bool = false
    @Published var showErrorAlert               : Bool = false
    @Published var showSuccessAlert             : Bool = false
    @Published var shouldExitImmediately        : Bool  = false
    @Published var activeError                  : PerformanceRepository.PerformanceError?
    
    @Published var isPaused                     : Bool = false
    
    
    
    private let repository : PerformanceRepository
    private var cancellables = Set<AnyCancellable>()
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    private var isSlientStop = false
    
    private var isWaitingForPermission = false
    
    
    
    init(repository: PerformanceRepository = PerformanceRepository()){
        self.repository = repository
        setupBindings()
        
    }
    
    
    private func setupBindings(){
        
        repository.$locationAuthStatus
                .receive(on: RunLoop.main)
                .sink { [weak self] status in
                    guard let self = self else { return }
                    
                    if self.isWaitingForPermission {
                        
                        if status == .authorizedWhenInUse || status == .authorizedAlways {
                        
                            self.isWaitingForPermission = false
                            self.showErrorAlert = false
                        }
                        else if status == .denied {
                            self.isWaitingForPermission = false
                            self.activeError = .lDeniedOrRestricted
                            self.showErrorAlert = true
                        }
                    }
                }
                .store(in: &cancellables)
        
    repository.saveOperationCompleted
            .receive(on:RunLoop.main)
            .sink { [weak self] success in
                guard let self  = self else { return }
                if success {
                    let currentCount = UserDefaults.standard.integer(forKey: "completedDriveCount")
                    
                    UserDefaults.standard.set(currentCount + 1, forKey: "completedDriveCount")
                    
                    
                    if !self.isSlientStop {
                        self.showSuccessAlert = true
                    }
                    self.isSlientStop = false
                }
                
                else{
                    self.shouldExitImmediately = true
                }
            }
            .store(in: &cancellables)
        
        
        repository.$speed
            .map{ $0 }
            .assign(to: &$speed)
        
        repository.$maxSpeed
            .map{  String(format: "%.1f", $0)}
            .assign(to: &$maxSpeed)
        
        repository.$distance
            .map { String(format: "%.2f", $0)}
            .assign(to: &$distance)
        
        repository.$sessionTime
            .map {[weak self] time in
                self?.timeFormatter.string(from: time) ?? "00:00:00"}
            .assign(to: &$sessionTime)
        
        repository.$bestZeroToHundred
            .map {
                if $0 > 1000 {
                    return  "00:00" }
                else {
                    return  String(format: "%.1f", $0)
        
                }
            }
            .assign(to: &$zeroToHundred)
        
        repository.$bestZeroToTwoHundred
            .map {
                if $0 > 1000 {
                    return  "00:00" }
                else {
                    return  String(format: "%.1f", $0)
                }
            }
            .assign(to: &$zeroToTwoHundred)
                    
        repository.$brakingDistanceHundredToZero
            .map { String(format: "%.1f", $0) }
            .assign(to: &$brakingDistanceHundredToZero)
        
        repository.$gForce
                .receive(on: RunLoop.main) 
                .sink { [weak self] newValue in
                     
                    self?.gForce = String(format: "%.2f", abs(newValue - 1))
                    
                }
                .store(in: &cancellables)
    }
    
    
  
    
    
    
    func toggleTracking()->Bool {
        if let  error : PerformanceRepository.PerformanceError =  repository.checkManagersAvaliability() {
            self.activeError = error
            self.showErrorAlert = true
            return false
        }
        
        let status = repository.locationAuthStatus
        if status == .notDetermined {
                 
                    self.isWaitingForPermission = true
                    return false
            }
                
        if status == .authorizedAlways || status == .authorizedWhenInUse {
                    repository.start()
                    isDriveViewActive = true
                    return true
            }
                
            return false
    }
    
    func stopTracking(isSlient : Bool = false){
        self.isSlientStop = isSlient
        repository.stopTracking()
    }
    
    func clearViewModel(){
        speed                         = 0.0
        sessionTime                   = "00:00:00"
        maxSpeed                      = "0.0"
        distance                      = "0.0"
        sessionTime                   = "0:00"
        zeroToHundred                 = "0:00"
        zeroToTwoHundred              = "0.00"
        brakingDistanceHundredToZero  = "0.00"
        gForce                        = "0.0"
        
        showErrorAlert                = false
        showSuccessAlert              = false
        shouldExitImmediately         = false
        isDriveViewActive             = false
        
        
    }
    
    func pauseTracikng(){
        repository.pauseTracking()
        speed = 0.0
        isPaused = true
    }
    func resumeTracking(){
        repository.resumeTracking()
        isPaused = false
    }
    
}
