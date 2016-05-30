//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-05-30.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let Photo = "photo"
        static let Title = "title"
    }
    
    @NSManaged var title: String
    @NSManaged var id: NSNumber
    @NSManaged var imagePath: String?
    @NSManaged var pin: Pin?
}
