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
    }
    
    @NSManaged var lat: NSNumber
    @NSManaged var lon: NSNumber
    @NSManaged var photos: [Photo]
    
    
}
