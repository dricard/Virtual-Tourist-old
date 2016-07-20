//
//  PictureViewController.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-05-03.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import UIKit
import MapKit

class PictureViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    
    var focusRegion: MKCoordinateRegion?
    let networkAPI = FlickrAPI()
    var pin: Pin?
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the map portion of the screen with the pin location
        mapView.setRegion(focusRegion!, animated: false)
        // Drop a pin in this mapView at the same place as in the MapViewController

        let lat = focusRegion?.center.latitude
        let long = focusRegion?.center.longitude
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.title = "Tap to see pictures of this location"
        
        mapView.addAnnotation(annotation)

        // DEBUG
        print("Sending request to Flickr API")
        if let pin = pin {
            networkAPI.sendRequest(pin) { (photos, success, error) in
                print("request completed")
            }
        }
        
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
