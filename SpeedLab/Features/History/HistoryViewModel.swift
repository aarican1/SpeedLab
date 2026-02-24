//
//  HistoryViewModel.swift
//  SpeedLab
//
//  Created by Abdurrahman Arıcan on 2.02.2026.
//

import Foundation
import CoreData
import Combine

final class HistoryViewModel :NSObject, ObservableObject {
    
    @Published var sessions: [DriveSession] = []
    @Published var isLoading:Bool = false
    
    private let coreDataManager = CoreDataManager.shared
    private var fetchedResultsController: NSFetchedResultsController<DriveSession>!
    
    override init() {
        super.init()
        setupFetcher()
    }
    
    private func setupFetcher(){
        let request: NSFetchRequest<DriveSession> = DriveSession.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DriveSession.timestamp, ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest : request,
            managedObjectContext: coreDataManager.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            self.sessions = fetchedResultsController.fetchedObjects ?? []
        } catch {
            
        }
    }
    
    func deleteSession(at offsets: IndexSet) {
        offsets.map{(sessions[$0])}.forEach{ session in
            coreDataManager.deleteSession(session)
        }
    }
}


extension HistoryViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let newSessions = controller.fetchedObjects as? [DriveSession] else { return }
        self.sessions = newSessions
    }
}
