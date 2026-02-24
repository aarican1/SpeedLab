//
//  LocationManager.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 28.01.2026.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager:NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location : CLLocation?
    @Published var authorizationStatus : CLAuthorizationStatus?

    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.activityType = .automotiveNavigation
        
        self.authorizationStatus = locationManager.authorizationStatus
    }
    
    
    func requestLocationPermission(){
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    func startUpdatingLocation(){
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.startUpdatingLocation()
    }
    
    
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
        self.location = nil
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        self.location = lastLocation
    }
    
}
