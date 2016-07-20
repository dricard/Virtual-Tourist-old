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
            static let instance = CoreDataStackManager()
        }
        
        return Static.instance
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
    

    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.hexaedre.Virtual_Tourist" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}
