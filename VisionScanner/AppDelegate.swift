//
//  AppDelegate.swift
//  VisionScanner
//
//  Created by Alfian Losari on 01/09/17.
//  Copyright © 2017 Alfian Losari. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var homeViewController: HomeViewController {
        return (self.window!.rootViewController as! UINavigationController).viewControllers[0] as! HomeViewController
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "VisionScanner")
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Fatal Error: \(error.localizedDescription)")
            }
            
        })
        return persistentContainer
    }()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        let moc = persistentContainer.viewContext
        homeViewController.managedObjectContext = moc
        return true
    }

}

