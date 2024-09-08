//
//  DefaultPersistenceCoreDataService.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 25/01/2022.
//

import CoreData

class DefaultPersistenceCoreDataService: PersistenceCoreDataService {
    
    let container: NSPersistentContainer
    
    required init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GeengGoong")
        let persistentStoreDescription = container.persistentStoreDescriptions.first
        
        if inMemory {
            persistentStoreDescription?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Error loading persistent store \(error.localizedDescription)")
            }
        }
        
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType
        
        if !inMemory {
            do {
                try viewContext.setQueryGenerationFrom(.current)
            } catch {
                let nsError = error as NSError
                print("Failed to pin viewContext to the current generation: \(nsError.localizedDescription)")
            }
        }
    }
}
