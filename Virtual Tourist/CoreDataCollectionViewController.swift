//
//  CoreDataCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-07-20.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "PhotoCell"

class CoreDataCollectionViewController: UICollectionView {

    var insertedIndexCache: [NSIndexPath]!

    // MARK:  - Properties
    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
            // Whenever the frc changes, we execute the search and
            // reload the table
//            fetchedResultsController?.delegate = self
            executeSearch()
//            collectionView?.reloadData()
        }
    }
    
//    init(fetchedResultsController fc : NSFetchedResultsController) {
//        fetchedResultsController = fc
//        super.init
//    }
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

// MARK: - Subclass responsibility
extension CoreDataCollectionViewController {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataCollectionViewController")
    }
}

// MARK: - Collection View Data Source
extension CoreDataCollectionViewController {
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
}

// MARK: - Fetches
extension CoreDataCollectionViewController {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let error as NSError {
                print("Error while trying to perform a search: \n\(error)\n\(fetchedResultsController)")
            }
        }
    }
}

// MARK: - Delegates
//extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        insertedIndexCache = [NSIndexPath]()
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        
//        switch type {
//        case .Insert:
//            insertedIndexCache.append(newIndexPath!)
//        default:
//            break
//        }
//    }
//    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        collectionView!.performBatchUpdates({
//            self.collectionView!.insertItemsAtIndexPaths(self.insertedIndexCache)
//            
//            }, completion: nil)
//    }
//
//}