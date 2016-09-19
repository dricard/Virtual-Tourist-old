//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-05-02.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import CoreData

private let SQLITE_FILE_NAME = "VirtalTourist.sqlite"
private let modelName = "Virtual_Tourist"

class CoreDataStack {

    // MARK: Shared Instance
    
    class func sharedInstance() -> CoreDataStack {
        struct Singleton {
            static var sharedInstance = CoreDataStack()
        }
        return Singleton.sharedInstance
    }
   
   // SWIFT 3 stack
   
   // MARK: - Core Data stack
   
   @available(iOS 10.0, *)
   lazy var persistentContainer: NSPersistentContainer = {
      /*
       The persistent container for the application. This implementation
       creates and returns a container, having loaded the store for the
       application to it. This property is optional since there are legitimate
       error conditions that could cause the creation of the store to fail.
       */
      let container = NSPersistentContainer(name: "Virtual_Tourist")
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
         if let error = error as NSError? {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            fatalError("Unresolved error \(error), \(error.userInfo)")
         }
      })
      return container
   }()
   
   // MARK: - Core Data Saving support
   
   @available(iOS 10.0, *)
   func saveContext () {
      let context = persistentContainer.viewContext
      if context.hasChanges {
         do {
            try context.save()
         } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
         }
      }
   }

/* PRE-iOS 10 code

    // MARK: - Properties
    fileprivate let model: NSManagedObjectModel
    fileprivate let coordinator: NSPersistentStoreCoordinator
    fileprivate let modelURL: URL
    fileprivate let dbURL: URL
    fileprivate let persistingContext: NSManagedObjectContext
    fileprivate let backgroundContext: NSManagedObjectContext
    let context: NSManagedObjectContext
    
    // MARK: - Initializers
    
    init?(modelName: String) {
        
        // Assumes the model in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName) in main bundle")
            return nil
        }
        
        self.modelURL = modelURL
        
        // try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Unable to create model from \(modelURL)")
            return nil
        }
        
        self.model = model
        
        // create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // create a persisting context (private queue) connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        // create a context (main queue) and set as child of the persistingContext
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        
        // create a background context (private queue) and set as child of the main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        // add a SQLite store located in the documents folder
        let fm = FileManager.default
        
        guard let docURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach the documents folder")
            return nil
        }
        
        self.dbURL = docURL.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
        // add the store to coordinator
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
        } catch {
            print("Unable to add store at \(dbURL)")
        }
        
    }
}

// MARK: - Batch processing in the background
extension CoreDataStack {
    
    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    func performBackgroundBatchOperation(_ batch: @escaping Batch) {
        
        backgroundContext.perform() {
            batch(self.backgroundContext)
            
            // save it to the parent context, sor normal saving can work
            do {
                try self.backgroundContext.save()
            } catch {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
}

// MARK: - Core Data debuggin support

// These methods are designed to help set-up static data to
// debug Core Data
extension CoreDataStack {
    
    func dropAllData() throws {
        // delete all objects in the database (without deleting the database itself)
        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
        
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
    
}


// MARK: - Core Data Saving support
extension CoreDataStack {
    func save() {
        // We call this synchronously, but it's a very fast
        // operation (it doesn't hit the disk). We need to know
        // when it ends so we can call the next save (on the persisting
        // context). This last one might take some time and is done
        // in a background queue
        context.performAndWait() {
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
                
                // now save in the background
                self.persistingContext.perform() {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    func autoSave(_ delayInSeconds: Int) {
        
        if delayInSeconds > 0 {
            save()
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: { 
                self.autoSave(delayInSeconds)
            })
        }
    }
    END OF PRE-iOS 10 code */
}
