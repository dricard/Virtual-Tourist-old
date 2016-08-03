//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-05-02.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import CoreData
import MapKit

class Pin: NSManagedObject, MKAnnotation {

    // MARK: - Properties
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(45.50, -73.78)
    
    struct Keys {
        static let Lattitude = "lat"
        static let Longitude = "lon"
        static let Photos = "photos"
    }
    
    @NSManaged var lat: NSNumber
    @NSManaged var lon: NSNumber
    @NSManaged var photos: NSSet
    
    convenience init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: entity, insertIntoManagedObjectContext: context)
            self.coordinate = coordinate

            self.lat = Double(coordinate.latitude)
            self.lon = Double(coordinate.longitude)
        } else {
            fatalError("Unable to find Entity named 'Pin'")
        }
        
    }
    
}
