//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-06-08.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FlickrAPI: NSObject {

    
    // MARK: - Properties
    
    static let flickrAPIKey = API_KEY
    static let flickrSecret = API_SECRET
    
    static let session = NSURLSession.sharedSession()
    let stack = CoreDataStack.sharedInstance()

    static func sendRequest(pin: Pin, completionHandlerForRequest: (photos: [Photo]?, success: Bool, error: NSError?) -> Void) {

        // 1. create the parameters dictionary used by URLByAppendingQueryParameters
        let URLParams = [
            "method": Constants.Flickr.PhotoSearchMethod,
            "lat": "\(pin.lat)",
            "lon": "\(pin.lon)",
            "format": "json",
            "extras": "url_m",
            "nojsoncallback": "1",
            "api_key": flickrAPIKey,
            "radius": Constants.Flickr.PhotoSearchRadius
            ]
        
        // 2. Build URL
        guard var URL = NSURL(string: Constants.Flickr.FlickrBaseURL) else {return}
        URL = URL.URLByAppendingQueryParameters(URLParams)
        // DEBUG
        print(URL)
        // 3. configure the request
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        
        // Headers
        
//        request.addValue("xb=401957", forHTTPHeaderField: "Cookie")
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            // Utility function
            func sendError(error: String, code: Int) {
                print("error: \(error), code: \(code)")
                // Build an informative NSError to return
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForRequest(photos: nil, success: false, error: NSError(domain: "sendRequest", code: code, userInfo: userInfo))
            }

            // GUARD: was there an error?
            guard (error == nil) else {
                sendError("There was an error with the request to Flickr API: \(error)", code: Constants.Flickr.networkError)
                return
            }

            // GUARD: did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                let theStatusCode = (response as? NSHTTPURLResponse)?.statusCode
            sendError("Your request to Flickr returned a status code outside the 200 range: \(theStatusCode)", code: Constants.Flickr.requestError)
            return
            }

            // GUARD: was there data returned?
            guard let data = data else {
                sendError("No data was returned by the request!", code: Constants.Flickr.noDataError)
                return
            }
    
            // 5. Parse the data
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data returned by Flickr: \(data)", code: Constants.Flickr.parseError)
            }
    
            // 6. Use the data

            // GUARD: get the photos from the data
            guard let photoArray = parsedResult[Constants.Flickr.Photos]!![Constants.Flickr.Photo] as? [[String:AnyObject]] else {
                sendError("Could not parse photos from the data", code: Constants.Flickr.noPhotoDataError)
                return
            }
            print("We got to HERE 001")
    
            var photos = [Photo]()
            
            for dictionary in photoArray {
                let photo = Photo(dictionary: dictionary, context: CoreDataStack.sharedInstance().context)
                photos.append(photo)
            }

            print("We got to HERE 002")

            completionHandlerForRequest(photos: photos, success: true, error: nil)

        })
        task.resume()
    }
}


protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {

    /// This computed property returns a query parameters string from the given NSDictionary.
    /// - note: For example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
    /// string will be @"day=Tuesday&month=January".
    /// - returns:
    ///     - The computed parameters string.
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = NSString(format: "%@=%@",
                                String(key).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!,
                                String(value).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
            parts.append(part as String)
        }
        return parts.joinWithSeparator("&")
    }
    
}

extension NSURL {

    /// Creates a new URL by adding the given query parameters.
    /// - parameters:
    ///     - parametersDictionary The query parameter dictionary to add.
    /// - returns:
    ///     - A new NSURL.
    func URLByAppendingQueryParameters(parametersDictionary : Dictionary<String, String>) -> NSURL {
        let URLString : NSString = NSString(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return NSURL(string: URLString as String)!
    }
}


