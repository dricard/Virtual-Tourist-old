//
//  ManagedObject.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-08-15.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import CoreData

// useful because of the way generic types are handled
open class ManagedObject: NSManagedObject {
}

// Our model(s) class(es) will implement this and make sure they provide proper
// entityName(s) and defaults.
public protocol ManagedObjectType: class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
//    static var defaultPredicate: NSPredicate { get }
    var managedObjectContext: NSManagedObjectContext? { get }
}

// This is a default implementation of the protocol, providing default values
extension ManagedObjectType {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
//    public static var sortedFetchedRequest: NSFetchRequest {
//        let request = NSFetchRequest(entityName: entityName)
//        request.sortDescriptors = defaultSortDescriptors
//        request.predicate = defaultPredicate
//        return request
//    }
//    
//    public static func sortedFetchedRequestWithPredicate(predicate: NSPredicate) -> NSFetchRequest {
//        let request = sortedFetchRequest
//        guard let exostingPredicate = request.predicate else { fatalError("must have predicate") }
//        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, predicate])
//        return request
//    }
    
}
