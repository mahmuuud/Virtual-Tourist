//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by mahmoud mohamed on 5/10/19.
//  Copyright © 2019 mahmoud mohamed. All rights reserved.
//

import UIKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "VirtualTourist-DataModel")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()
        let mapVC = window?.rootViewController as! MapVC
        mapVC.span = getZoomLevel()
        mapVC.dataController = self.dataController
        return true
    }
    
    func getZoomLevel()->MKCoordinateSpan{
        if UserDefaults.standard.value(forKey: "spanLat") != nil && UserDefaults.standard.value(forKey: "spanLon") != nil{
            print ("launched before")
            let lat = UserDefaults.standard.value(forKey: "spanLat") as! Double
            let lon = UserDefaults.standard.value(forKey: "spanLon") as! Double
            return MKCoordinateSpan(latitudeDelta: lat, longitudeDelta: lon)
        }
        print("first launch")
        // Default zoom
        UserDefaults.standard.set(24.51356906522969, forKey: "spanLat")
        UserDefaults.standard.set(12.7441409999999, forKey: "spanLon")
        UserDefaults.standard.synchronize()
        return MKCoordinateSpan(latitudeDelta: 24.51356906522969, longitudeDelta: 12.7441409999999)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        try? dataController.viewContext.save()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try? dataController.viewContext.save()
    }


}

