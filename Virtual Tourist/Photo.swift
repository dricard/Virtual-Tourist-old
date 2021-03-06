//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-05-30.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import UIKit
import CoreData

class Photo: ManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let Pin = "pin"
        static let Title = "title"
        static let ImagePath = "url_m"
    }
    
    @NSManaged var title: String
    @NSManaged var id: String
    @NSManaged var imagePath: String?
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String:Any], context: NSManagedObjectContext) {
        
        // Core Data
        if let entity = NSEntityDescription.entity(forEntityName: Photo.entityName, in: context) {
            super.init(entity: entity, insertInto: context)
            
            // Dictionary
            title = dictionary[Keys.Title] as! String
            id = dictionary[Keys.ID] as! String
            imagePath = dictionary[Keys.ImagePath] as? String
            guard imagePath != nil else {
                return
            }
            if let validatedURL = validateURL(imagePath!) {
                // looks good.
                // change url to the reconditionned one
                // in case some parts were fixed
                imagePath = validatedURL
            } else {
                imagePath = nil
            }
        } else {
            fatalError("Unable to find Entity named 'Photo'")
        }
    }
    
    // This is a modified version of something found on stackoverflow
    
    /// Returns a validated (format only) URL or nil if not able to
    /// make one with the supplied url.
    /// - parameters:
    ///    - url: the String associated with the mediaURL on Flickr.
    /// - returns:
    ///    - a valid url in a String, or
    ///    - `nil` if unsuccessful.
    fileprivate func validateURL(_ url: String) -> String? {
        
        let types: NSTextCheckingResult.CheckingType = .link
        
        var detector: AnyObject!
        do {
            detector = try NSDataDetector(types: types.rawValue)
        } catch {
            print("Error validating URL: \(url)")
            return nil
        }
        
        guard let detect = detector else {
            return nil
        }
        
        let matches = detect.matches(in: url, options: .reportCompletion, range: NSMakeRange(0, url.characters.count))
        
        if !matches.isEmpty {
            if let validURL = matches[0].url {
                return String(describing: validURL)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

}

extension Photo: ManagedObjectType {
    public static var entityName: String {
        return "Photo"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "title", ascending: true)]
    }
    
//    public static defaultPredicate: NSPredicate {
//        return
//    }
    
}
