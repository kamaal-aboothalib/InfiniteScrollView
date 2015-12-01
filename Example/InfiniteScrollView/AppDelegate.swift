//
//  AppDelegate.swift
//  InfiniteScrollView
//
//  Created by garazha on 4/22/15.
//  Copyright (c) 2015 Sergey Garazha. All rights reserved.
//

import UIKit

var images = [UIImage]()
var models = [Model]()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        for i in 1...7 {
            let image = UIImage(named: "\(i).jpg")
            images.append(image!)
        }
        
        let urls = ["http://dreamatico.com/data_images/kitten/kitten-1.jpg", "http://i.telegraph.co.uk/multimedia/archive/02830/cat_2830677b.jpg", "http://weknowyourdreams.com/image.php?pic=/images/kitten/kitten-09.jpg", "http://dreamatico.com/data_images/kitten/kitten-2.jpg", "https://pbs.twimg.com/profile_images/562466745340817408/_nIu8KHX.jpeg", "http://www.eastcottvets.co.uk/uploads/Animals/gingerkitten.jpg", "http://weknowyourdreams.com/image.php?pic=/images/kittens/kittens-06.jpg"]
        
        for i in 0...6 {
            let model = Model()
            model.url = urls[i]
            models.append(model)
        }
        
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
    }


}

