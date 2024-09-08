//
//  PersistenceCoreDataService.swift
//  Geeng Goong
//
//  Created by Elankumaran Tharsan on 21/12/2021.
//

import CoreData

protocol PersistenceCoreDataService {
    init(inMemory: Bool)
    
    var viewContext: NSManagedObjectContext { get }
    var container: NSPersistentContainer { get }
    
    func fetchItems<T: NSManagedObject>(entity: T.Type,
                                        predicate: NSPredicate?,
                                        range: (limit: Int, offset: Int?)?,
                                        sortDescriptors: [NSSortDescriptor]?,
                                        completion: @escaping (Result<[T], PersistenceError>) -> Void)
    
    func addNewItem(completionInsert: @escaping (NSManagedObjectContext) -> Void,
                    completion: ((PersistenceError?) -> Void)?)
    
    func insertItems(completionItems: @escaping (NSManagedObjectContext) -> [NSManagedObject],
                     entity: NSEntityDescription,
                     completion: ((PersistenceError?) -> Void)?)
    
    func deleteManagedObjects(_ objects: [NSManagedObject],
                              completion: ((PersistenceError?) -> Void)?)
    
    func deleteItems<T: NSManagedObject>(entity: T.Type,
                                         predicate: NSPredicate?,
                                         range: (limit: Int, offset: Int?)?,
                                         sortDescriptors: [NSSortDescriptor]?,
                                         completion: ((PersistenceError?) -> Void)?)
}

// MARK: - Implementation
extension PersistenceCoreDataService {
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    // MARK: - Fetch
    func fetchItems<T: NSManagedObject>(entity: T.Type,
                                        predicate: NSPredicate? = nil,
                                        range: (limit: Int, offset: Int?)? = nil,
                                        sortDescriptors: [NSSortDescriptor]? = nil,
                                        completion: @escaping (Result<[T], PersistenceError>) -> Void) {
        
        viewContext.perform { [context = viewContext] in
            do {
                let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: String(describing: T.self))
                
                if let predicate = predicate {
                    request.predicate = predicate
                }
                request.sortDescriptors = sortDescriptors
                
                if let range = range {
                    request.fetchLimit = range.limit
                    if let offset = range.offset {
                        request.fetchOffset = offset
                    }
                }
                
                let results = try context.fetch(request)
                completion(.success(results))
            } catch {
                print(error)
                completion(.failure(.fetchItemsFailed))
            }
        }
    }
    
    // MARK: - Add Item
    func addNewItem(completionInsert: @escaping (NSManagedObjectContext) -> Void,
                    completion: ((PersistenceError?) -> Void)?) {
        viewContext.perform { [context = viewContext] in
            completionInsert(context)
            do {
                try self.saveViewContext()
                completion?(nil)
            } catch {
                print(error)
                completion?(.addNewItemFailed)
            }
        }
    }
    
    // MARK: - Insert Items
    func insertItems(completionItems: @escaping (NSManagedObjectContext) -> [NSManagedObject],
                     entity: NSEntityDescription,
                     completion: ((PersistenceError?) -> Void)?) {
        
        container.performBackgroundTask { context in
            let items = completionItems(context)
            
//            if #available(iOS 14.0, *) {
//                let batchInsert = self.newBatchInsertRequest(with: items, entity: entity)
//                do {
//                    try context.execute(batchInsert)
//                } catch {
//                    let nsError = error as NSError
//                    print("Error batch inserting fireballs \(nsError.userInfo)")
//                }
//            } else {
            do {
                try self.insertOldWayItems(items, context: context)
                DispatchQueue.main.async {
                    completion?(nil)
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    completion?(.insertionFailed)
                }
            }
                
//            }
        }
    }
    
    // MARK: - Delete Objects
    func deleteManagedObjects(_ objects: [NSManagedObject],
                              completion: ((PersistenceError?) -> Void)?) {
        viewContext.perform { [context = viewContext] in
            objects.forEach(context.delete)
            do {
                try self.saveViewContext()
                completion?(nil)
            } catch {
                completion?(.deletionFailed)
            }
        }
    }
    
    // MARK: - Delete Items
    func deleteItems<T: NSManagedObject>(entity: T.Type,
                                         predicate: NSPredicate?,
                                         range: (limit: Int, offset: Int?)? = nil,
                                         sortDescriptors: [NSSortDescriptor]? = nil,
                                         completion: ((PersistenceError?) -> Void)?) {
        viewContext.perform { [context = viewContext] in
            do {
                let request = T.fetchRequest()
                if let predicate = predicate {
                    request.predicate = predicate
                }
                request.sortDescriptors = sortDescriptors
                
                if let range = range {
                    request.fetchLimit = range.limit
                    if let offset = range.offset {
                        request.fetchOffset = offset
                    }
                }
                let deletionrequest = NSBatchDeleteRequest(fetchRequest: request)
                try context.execute(deletionrequest)
                completion?(nil)
            } catch {
                print(error)
                completion?(.deletionFailed)
            }
        }
    }
    
    // MARK: - Private
    private func saveViewContext() throws {
        guard viewContext.hasChanges else { return }
        
        try viewContext.save()
    }
    
    @available(iOS 14.0, *)
    private func newBatchInsertRequest(with items: [NSManagedObject],
                                       entity: NSEntityDescription) -> NSBatchInsertRequest {

        // Source : https://medium.com/@vanita.ladkat/core-data-convert-nsmanagedobject-array-to-json-array-ffe5aca21eb5
        func convertToJSONArray(moArray: [NSManagedObject]) -> [[String: Any]] {
            var jsonArray: [[String: Any]] = []
            for item in moArray {
                var dict: [String: Any] = [:]
                
                for attribute in item.entity.attributesByName {
                    //check if value is present, then add key to dictionary so as to avoid the nil value crash
                    if let value = item.value(forKey: attribute.key) {
                        dict[attribute.key] = value
                    }
                }
                jsonArray.append(dict)
            }
            return jsonArray
        }

        let ob = convertToJSONArray(moArray: items)
        return NSBatchInsertRequest(entity: entity, objects: ob)
    }
    
    private func insertOldWayItems(_ items: [NSManagedObject],
                                   context: NSManagedObjectContext) throws {
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        try items.forEach { item in
            try context.save()
        }
    }
}
