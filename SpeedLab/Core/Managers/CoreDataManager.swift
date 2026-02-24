//
//  CoreDataManager.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 1.02.2026.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    
    let container: NSPersistentContainer
    
    init(inMemory:Bool = false){
        
        container = NSPersistentContainer(name: "DriveSessionModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
    }
    
    func saveContext(){
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                
            }
        }
    }
    
    
    func saveSession(maxSpeed: Double,
                    distance: Double,
                    duration: Double,
                    zeroToHundred: Double,
                    zeroToTwoHundred: Double,
                    brakingDistance: Double,
                    maxGForce: Double){
        
        let context = container.viewContext
        
        let newSession = DriveSession(context: context)
        
        newSession.timestamp = Date()
        newSession.maxSpeed = maxSpeed
        newSession.distance = distance
        newSession.duration = duration
        newSession.zeroToHundred = zeroToHundred
        newSession.zeroToTwoHundred = zeroToTwoHundred
        newSession.brakingDistance = brakingDistance
        newSession.maxGForce = maxGForce

        saveContext()
    }
    
    func deleteSession( _ session: DriveSession ) {
        let context = container.viewContext
        
        context.delete(session)
        saveContext()
        
    }
}
