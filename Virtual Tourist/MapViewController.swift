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
        longPressRec.minimumPressDuration = 1.0
        longPressRec.numberOfTouchesRequired = 1
        view!.addGestureRecognizer(longPressRec)
        
        mapView.delegate = self
        
    }
    
    // MARK: - MapView Delegates
    
    
    // MARK: - User Actions
    
    func userLongPressed() {
        print("User long pressed!!")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
