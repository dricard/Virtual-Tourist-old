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
   
   static let session = URLSession.shared
   static let context = CoreDataStack.sharedInstance().persistentContainer.viewContext
   
   static func sendRequest(_ pin: Pin, completionHandlerForRequest: @escaping (_ photos: [[String:Any]]?, _ success: Bool, _ error: NSError?) -> Void) {
      
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
      guard var URL = URL(string: Constants.Flickr.FlickrBaseURL) else {return}
      URL = URL.URLByAppendingQueryParameters(URLParams)
      // DEBUG
      print(URL)
      // 3. configure the request
      let request = NSMutableURLRequest(url: URL)
      request.httpMethod = "GET"
      
      // Headers
      
      //        request.addValue("xb=401957", forHTTPHeaderField: "Cookie")
      
      // 4. Make the request
      let task = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
         
         // Utility function
         func sendError(_ error: String, code: Int) {
            print("error: \(error), code: \(code)")
            // Build an informative NSError to return
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandlerForRequest(nil, false, NSError(domain: "sendRequest", code: code, userInfo: userInfo))
         }
         
         // GUARD: was there an error?
         guard (error == nil) else {
            sendError("There was an error with the request to Flickr API: \(error)", code: Constants.Flickr.networkError)
            return
         }
         
         // GUARD: did we get a successful 2XX response?
         guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            let theStatusCode = (response as? HTTPURLResponse)?.statusCode
            sendError("Your request to Flickr returned a status code outside the 200 range: \(theStatusCode)", code: Constants.Flickr.requestError)
            return
         }
         
         // GUARD: was there data returned?
         guard let data = data else {
            sendError("No data was returned by the request!", code: Constants.Flickr.noDataError)
            return
         }
         
         // 5. Parse the data
         
         
         let parsedResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]

         // 6. Use the data
         
         // GUARD: get the photos root object from the parsed data
         guard let photoElement = parsedResult??[Constants.Flickr.Photos] as? [String:Any] else {
            sendError("Could not parse photos from the data", code: Constants.Flickr.noPhotoDataError)
            return
         }
         // Now get the photos array from that root object
         guard let photoArray = photoElement[Constants.Flickr.Photo] as? [[String:Any]] else {
            sendError("Could not parse photo from the data", code: Constants.Flickr.noPhotoDataError)
            return
         }
         
         print("We got to HERE 001")
         
//         var photos = [Photo]()
//         
//         for dictionary in photoArray {
//            let photo = Photo(dictionary: dictionary, context: context)
//            photos.append(photo)
//         }
         
         print("We got to HERE 002")
         
         completionHandlerForRequest(photoArray, true, nil)
         
         return()
         
      }).resume()
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
                             String(describing: key).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!,
                             String(describing: value).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
         parts.append(part as String)
      }
      return parts.joined(separator: "&")
   }
   
}

extension URL {
   
   /// Creates a new URL by adding the given query parameters.
   /// - parameters:
   ///     - parametersDictionary The query parameter dictionary to add.
   /// - returns:
   ///     - A new NSURL.
   func URLByAppendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
      let URLString : NSString = NSString(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
      return URL(string: URLString as String)!
   }
}


