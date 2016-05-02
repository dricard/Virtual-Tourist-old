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
        
    }
    
    // MARK: - MapView Delegates
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if let pin = pinView {
            pin.annotation = annotation
        } else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.blackColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        
        return pinView
        
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
        
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
