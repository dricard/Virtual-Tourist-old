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
   var photos = [Photo]()
   
   var screenWidth: CGFloat = 0
   var screenHeight: CGFloat = 0
   let context = CoreDataStack.sharedInstance().persistentContainer.viewContext
   
   // MARK: - Outlets
   
   
   // MARK: - Fetched Results Controller
   
   func fetchedResultsController() -> NSFetchedResultsController<Photo> {
      
      // Create the fetch request
      let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
      
      // Add a sort descriptor.
      fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
      
      // Add a predicate (if relation is to-many: one actor has many movie objects)
      fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
      
      // Create the Fetched Results Controller
      let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
      
      // Return the fetched results controller. It will be the value of the lazy variable
      return fetchedResultsController
   }
   
   // MARK: - Outlets
   
   @IBOutlet weak var mapView: MKMapView!
   @IBOutlet weak var collectionView: UICollectionView!
   @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
   
   // MARK: - Lyfe Cycle
   
   override func viewWillAppear(_ animated: Bool) {
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
      
      photos = fetchAllPhotos()
      if photos.isEmpty {
         print("We DON'T have photos at this location, searching API")
         /* DEBUG */
         print("Sending request to Flickr API")
         if let pin = pin {
            FlickrAPI.sendRequest(pin) { (photos, success, error) in
               print("request completed")
               
               // make sure the request was succellful
               guard success else {
                  print("Request to Flickr API failed with error: \(error)")
                  return
               }
               
               guard let photos = photos else {
                  print("No photos in returned data from Flickr")
                  return
               }
               
               self.photos = photos
               self.collectionView?.reloadData()
               
            }
         }
         
      } else {
         print("We have photos at this location, displaying")
      }
      
   }
   
   // MARK: - Utilities
   
   func fetchAllPhotos() -> [Photo] {
      
      var error: NSError? = nil
      var results: [Photo]?
      
      let fetchRequest = NSFetchRequest<Photo>()
      let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context)
      fetchRequest.entity = entity
      
      let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
      fetchRequest.sortDescriptors = [sortDescriptor]
      
      fetchRequest.predicate = NSPredicate(format: "pin = %@", pin!)
      
      do {
         results = try context.fetch(fetchRequest) as! [Photo]
      } catch let error1 as NSError {
         error = error1
         results = nil
      } catch {
         print("Error")
      }
      
      if let error = error {
         print("ERROR fetching photos: \(error)")
      }
      
      if results == nil {
         return [Photo]()    // send back an empty array
      } else {
         return results!
      }
   }
   
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
      flowLayout.itemSize = CGSize(width: dimensionX, height: dimensionY)
      
   }
   
   override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
      setFlowLayout()
   }
}

extension PictureViewController: UICollectionViewDataSource {
   
   // MARK: - CollectionViewController subclass required methods
   
   func numberOfSections(in collectionView: UICollectionView) -> Int {
      //        return (self.fetchedResultsController.sections?.count)!
      return 0
   }
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
      return fetchedResultsController().sections![section].numberOfObjects
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
      // Create a cell
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
      
      // get the photo information from Core Data
      let photo = fetchedResultsController().object(at: indexPath) as! Photo
      
      // Configure the cell
      
      if let imagePath = photo.imagePath {
         let imageURL = URL(string: imagePath)
         if let imageData = try? Data(contentsOf: imageURL!) {
            cell.imageView.image = UIImage(data: imageData)
         }
      } else {
         cell.imageView.image = UIImage(named: "cube")
      }
      
      return cell
   }
   
}

extension PictureViewController: UICollectionViewDelegate {
   
   
}

extension PictureViewController: NSFetchedResultsControllerDelegate {
   
}
