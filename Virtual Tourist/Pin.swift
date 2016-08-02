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
    
    @NSManaged var lat: Double
    @NSManaged var lon: Double
    @NSManaged var photos: [Photo]
    
//    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
//        super.init(entity: entity, insertIntoManagedObjectContext: context)
//    }
    
    convenience init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: entity, insertIntoManagedObjectContext: context)
            self.coordinate = coordinate
//            print(Double(coordinate.latitude))
//            print(Double(coordinate.longitude))
            self.lat = Double(coordinate.latitude)
            self.lon = Double(coordinate.longitude)
            self.photos = [Photo]()
        } else {
            fatalError("Unable to find Entity named 'Pin'")
        }
        
    }
    
}
