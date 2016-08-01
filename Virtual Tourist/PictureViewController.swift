//
//  PictureViewController.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-05-03.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PictureViewController: UIViewController {
    
    // MARK: - Properties
    
    var focusRegion: MKCoordinateRegion?
    let networkAPI = FlickrAPI()
    var pin: Pin?
    
    var screenWidth: CGFloat = 0
    var screenHeight: CGFloat = 0
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    // MARK: - Lyfe Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setFlowLayout()
        collectionView?.reloadData()
    }
    
    override func viewDidLoad() {

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
//        print("Sending request to Flickr API")
//        if let pin = pin {
//            networkAPI.sendRequest(pin) { (photos, success, error) in
//                print("request completed")
//            }
//        }
        
    }
    
    // MARK: - Utilities
    
    func getScreenSize() {
        screenWidth = view.frame.size.width
        screenHeight = view.frame.size.height
    }
    
    func setFlowLayout() {
        
        // update screen size
        getScreenSize()
        
        let space: CGFloat = 3.0
        var dimensionX, dimensionY: CGFloat
        
        if screenHeight > screenWidth {
            dimensionX = (screenWidth - (1 * space)) / 2.0
            dimensionY = (screenHeight - ( 5 * space )) / 4.0
        } else {
            dimensionY = (screenHeight - 2 * space) / 2.0
            dimensionX = (screenWidth - ( 5 * space)) / 4.0
        }
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimensionX, dimensionY)
        
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        setFlowLayout()
    }
}

extension PictureViewController: UICollectionViewDataSource {

    // MARK: - CollectionViewController subclass required methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath)
        
        // Configure the cell
        
        return cell
    }

}

extension PictureViewController: UICollectionViewDelegate {
    
    
}