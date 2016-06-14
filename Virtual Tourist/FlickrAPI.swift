//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-06-08.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import UIKit

class API: NSObject {
    
    // MARK: - Properties
    
    var session = NSURLSession.sharedSession()
    let flickrAPIKey = API_KEY
    let flickrSecret = API_SECRET
    
    func getPhotosForLocation(lat: Double, lon: Double, completionHandlerForGetPhotos: (photos: [Photo]?, error: NSError?) -> Void) {
        
        
    }
}