//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Denis Ricard on 2016-05-02.
//  Copyright © 2016 Hexaedre. All rights reserved.
//

import UIKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let stack = CoreDataStack(modelName: "Virtual_Tourist")!

    func preloadData() {
        
        // first remove any data
        do {
            try stack.dropAllData()
        } catch {
            fatalError("Error dropping all objects in DB")
        }
        
        // create a pin and photos
        // first create a dictionary with the data
        let locationInfo = CLLocationCoordinate2DMake(45.5549318422931, -73.7842104341366)
        // then create a pin with that info
        let pin = Pin(coordinate: locationInfo, context: stack.context)
        
        // now let create some photos to add to that pin
        var photoInfo = [String:AnyObject]()
        photoInfo["title"] = "Bien avant Costco de nos jours..."
        photoInfo["id"] = "26749838213"
        photoInfo["imagePath"] = "https://farm8.staticflickr.com/7434/26749838213_f3583ba4fa.jpg"
        let photo = Photo(dictionary: photoInfo, context: stack.context)
        photo.pin = pin
        
        print(pin)
        print(photo)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // load some data
        preloadData()
        
        // start autosaving
        stack.autoSave(60)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        stack.save()
    }


}

