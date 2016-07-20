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

class CoreDataStackManager {


    // MARK: - Shared Instance
    
    /**
     *  This class variable provides an easy way to get access
     *  to a shared instance of the CoreDataStackManager class.
     */
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let stack = CoreDataStackManager(modelName: modelName)!
        }
        
        return Static.stack
    }

    // MARK: - Properties
    
    private let model: NSManagedObjectModel
    private let coordinator: NSPersistentStoreCoordinator
    private let modelURL: NSURL
    private let dbURL: NSURL
    private let persistingContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    let context: NSManagedObjectContext
    
    // MARK: - Initializers
    
    init?(modelName: String) {
        
        // Assumes the model in the main bundle
        guard let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension: "momd") else {
            print("Unable to find \(modelName) in main bundle")
            return nil
        }
        
        self.modelURL = modelURL
        
        // try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            print("Unable to create model from \(modelURL)")
            return nil
        }
        
        self.model = model
        
        // create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // create a persisting context (private queue) connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        // create a context (main queue) and set as child of the persistingContext
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = persistingContext
        
        // create a background context (private queue) and set as child of the main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        backgroundContext.parentContext = context
        
        // add a SQLite store located in the documents folder
        let fm = NSFileManager.defaultManager()
        
        guard let docURL = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
            print("Unable to reach the documents folder")
            return nil
        }
        
        self.dbURL = docURL.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
        // add the store to coordinator
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil)
        } catch {
            print("Unable to add store at \(dbURL)")
        }
        
    }
}

// MARK: - Batch processing in the background
extension CoreDataStackManager {
    
    typealias Batch = (workerContext: NSManagedObjectContext) -> ()
    
    func performBackgroundBatchOperation(batch: Batch) {
        
        backgroundContext.performBlock() {
            batch(workerContext: self.backgroundContext)
            
            // save it to the parent context, sor normal saving can work
            do {
                try self.backgroundContext.save()
            } catch {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
}

// MARK: - Core Data Saving support
extension CoreDataStackManager {
    func save() {
        // We call this synchronously, but it's a very fast
        // operation (it doesn't hit the disk). We need to know
        // when it ends so we can call the next save (on the persisting
        // context). This last one might take some time and is done
        // in a background queue
        context.performBlockAndWait() {
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
                
                // now save in the background
                self.persistingContext.performBlock() {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    func autoSave(delayInSeconds: Int) {
        
        if delayInSeconds > 0 {
            save()
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInNanoSeconds))
            
            dispatch_after(time, dispatch_get_main_queue(), { 
                self.autoSave(delayInSeconds)
            })
        }
    }

}
