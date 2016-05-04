//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-05-02.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Lyfe Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let longPressRec = UILongPressGestureRecognizer()
        longPressRec.addTarget(self, action: #selector(MapViewController.userLongPressed))
        longPressRec.allowableMovement = 25
        longPressRec.minimumPressDuration = 2.0
        longPressRec.numberOfTouchesRequired = 1
        view!.addGestureRecognizer(longPressRec)
        
        mapView.delegate = self
        
        // restore mapView to saved state
        restoreMapRegion(true)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        // We're going to another view, let's save the current state.
        saveMapRegion()
    }
    
    // MARK: - MapView Delegates
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if let pin = pinView {
            pin.annotation = annotation
        } else {
            print("adding a new annotation")
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.blackColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        
        return pinView
        
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    
        saveMapRegion()
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("in calloutAccessoryControlTapped")
        
        
    }
    
    
    // MARK: - User Actions
    
    @IBAction func userLongPressed(sender: AnyObject) {
        print("User long pressed!!")
        
        // Get the location of the longpress in mapView
        let location = sender.locationInView(mapView)
        
        // Get the map coordinate from the point pressed on the map
        let locationCoordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.title = "Tap to see pictures of this location"
        
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - Navigation

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    // MARK: - utilities
    
    /*  
        I made the design choice to persist the mapView state (visible region of the map)
        using the NSKeyedArchiver method. I'm using CoreData to persist the complex
        pins and pictures objects, but I feel that the current map state is more
        something that should be preserved with NSKeyedArchiver.
    */
    
    // Here we use the same filePath strategy for persisting the mapView state
    // A convenient property
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }

    func saveMapRegion() {
        
        // Place the "center" and "span" of the map into a dictionary
        // The "span" is the width and height of the map in degrees.
        // It represents the zoom level of the map.
        
        print("Saving map state")
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
 
        print("lat: \(dictionary["latitude"]), lon: \(dictionary["longitude"]), latD: \(dictionary["latitudeDelta"]), lonD: \(dictionary["longitudeDelta"])")

        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    func restoreMapRegion(animated: Bool) {
        
        // if we can unarchive a dictionary, we will use it to set the map back to its
        // previous center and span
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            print("lat: \(latitude), lon: \(longitude), latD: \(latitudeDelta), lonD: \(longitudeDelta)")
            
            mapView.setRegion(savedRegion, animated: animated)
        }
    }

}
