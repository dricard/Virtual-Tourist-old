//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-05-02.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import CoreData
import MapKit

class Pin: NSManagedObject {

    // MARK: - Properties
    
//    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(45.50, -73.78)
    
    struct Keys {
        static let Lattitude = "lat"
        static let Longitude = "lon"
        static let Photos = "photos"
    }
    
    @NSManaged var lat: NSNumber
    @NSManaged var lon: NSNumber
    @NSManaged var photos: NSSet
    
    convenience init(annotation: MKPointAnnotation, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: entity, insertIntoManagedObjectContext: context)

            self.lat = Double(annotation.coordinate.latitude)
            self.lon = Double(annotation.coordinate.longitude)
//            let tempCoordinates = CLLocationCoordinate2DMake(Double(annotation.coordinate.latitude), Double(annotation.coordinate.longitude))
//            self.coordinate = tempCoordinates
//            self.title = annotation.title
        } else {
            fatalError("Unable to find Entity named 'Pin'")
        }
        
    }
    
}
