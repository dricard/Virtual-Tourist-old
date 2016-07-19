//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-05-02.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import CoreData

class Pin: NSManagedObject {

    // MARK: - Properties
    
    struct Keys {
        static let Lattitude = "lat"
        static let Longitude = "lon"
        static let Photos = "photos"
    }
    
    @NSManaged var lat: NSNumber
    @NSManaged var lon: NSNumber
    @NSManaged var photos: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            super.init(entity: entity, insertIntoManagedObjectContext: context)
            lat = dictionary[Keys.Lattitude] as! Double
            lon = dictionary[Keys.Longitude] as! Double
        } else {
            fatalError("Unable to find Entity named 'Pin'")
        }
        
    }
    
}
