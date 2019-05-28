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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let mapVC = window?.rootViewController as! MapVC
        mapVC.span = setZoomLevel()
        return true
    }
    
    func setZoomLevel()->MKCoordinateSpan{
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

