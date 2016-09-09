//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-05-02.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    
    let longPressRec = UILongPressGestureRecognizer()
    let stack = CoreDataStack.sharedInstance()

    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Lyfe Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // configure the gesture recognizer for long presses
        longPressRec.addTarget(self, action: #selector(MapViewController.userLongPressed))
        longPressRec.allowableMovement = 25
        longPressRec.minimumPressDuration = 1.0
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

            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false // was true
            pinView!.pinTintColor = UIColor.blackColor()
//            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        
        return pinView
        
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    
        saveMapRegion()
        
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = (view.annotation?.coordinate)!
        
        let request = NSFetchRequest(entityName: "Pin")
        do {
            let results = try stack.context.executeFetchRequest(request) as! [Pin]
            if results.count > 0 {
                for result in results {
//                    print("result coordinates are: (\(result.lat), \(result.lon)) while annotation coordinates are: (\(annotation.coordinate.latitude), \(annotation.coordinate.longitude))")
                    if result.lat == annotation.coordinate.latitude && result.lon == annotation.coordinate.longitude {
                        let controller = storyboard!.instantiateViewControllerWithIdentifier("PictureViewController") as! PictureViewController
                        // Get the region to transfert
                        let longitude = annotation.coordinate.longitude
                        let latitude = annotation.coordinate.latitude
                        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        
                        let longitudeDelta = mapView.region.span.longitudeDelta
                        let latitudeDelta = mapView.region.span.latitudeDelta / 3
                        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
                        
                        let focusRegion = MKCoordinateRegion(center: center, span: span)
                        
                        
                        // Communicate the region of the map to show
                        controller.focusRegion = focusRegion
                        controller.pin = result
                        // if not part of a navigation stack, use this
                        presentViewController(controller, animated: true, completion: nil)
                        // if part of a navigation stack, use this instead
                        //        showViewController(controller, sender: self)
                        

                    }
                }
            }  else {
                print("No data found in Core Data")
                return
            }
        } catch let error as NSError {
            print("Fetch failed \(error): \(error.localizedDescription)")
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        print("in calloutAccessoryControlTapped")

//        let controller = storyboard!.instantiateViewControllerWithIdentifier("PictureViewController") as! PictureViewController

        let controller = storyboard!.instantiateViewControllerWithIdentifier("PictureViewController") as! PictureViewController

        // Get the region to transfert
        let longitude = view.annotation!.coordinate.longitude
        let latitude = view.annotation!.coordinate.latitude
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let longitudeDelta = mapView.region.span.longitudeDelta
        let latitudeDelta = mapView.region.span.latitudeDelta / 3
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        let focusRegion = MKCoordinateRegion(center: center, span: span)

        
        // Communicate the region of the map to show
        controller.focusRegion = focusRegion
        controller.pin = view.annotation as! Pin
        // if not part of a navigation stack, use this
        presentViewController(controller, animated: true, completion: nil)
        // if part of a navigation stack, use this instead
//        showViewController(controller, sender: self)

        
    }
    
    
    // MARK: - User Actions
    
    @IBAction func userLongPressed(sender: AnyObject) {
        

        if longPressRec.state == UIGestureRecognizerState.Began {
            // Get the location of the longpress in mapView
            let location = sender.locationInView(mapView)
            
            // Get the map coordinate from the point pressed on the map
            let locationCoordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
            
            // Create an annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationCoordinate
//            print("annotation added with coordinates: (\(annotation.coordinate.latitude), \(annotation.coordinate.longitude))")
            
//            print("Lat: \(locationCoordinate.latitude), lon: \(locationCoordinate.longitude)")
            let pin = Pin(annotation: annotation, context: stack.context)
            stack.save()
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - Navigation

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        guard let nc = segue.destinationViewController as? UINavigationController,
            let vc = nc.viewControllers.first as? PictureViewController
            else { fatalError("wrong view controller type") }
        vc.pin = sender as! Pin
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
        
//        print("Saving map state")
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
 
//        print("lat: \(dictionary["latitude"]), lon: \(dictionary["longitude"]), latD: \(dictionary["latitudeDelta"]), lonD: \(dictionary["longitudeDelta"])")

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
            
//            print("lat: \(latitude), lon: \(longitude), latD: \(latitudeDelta), lonD: \(longitudeDelta)")
            
            mapView.setRegion(savedRegion, animated: animated)
        }
    }

}
