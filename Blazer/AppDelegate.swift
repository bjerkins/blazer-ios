//
//  AppDelegate.swift
//  Blazer
//
//  Created by Bjarki Sorens on 27/08/15.
//  Copyright (c) 2015 someNerves. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var loginDelegate: SpotifyLoginDelegate?
    var loginViewController: UIViewController?
    var playbackController: PlaybackController?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // set login delegate 
        self.loginDelegate = self.window?.rootViewController as? PlaybackController
        
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        self.playbackController = storyBoard.instantiateInitialViewController() as? PlaybackController
        self.loginViewController = storyBoard.instantiateViewControllerWithIdentifier("LoginViewController") as? UIViewController
        
        self.window?.rootViewController = playbackController
        self.window?.makeKeyAndVisible()
        
        // check spotify auth token
        var auth = SPTAuth.defaultInstance()
        
        if auth.session == nil || !auth.session.isValid() { // no token received
            self.playbackController?.presentViewController(self.loginViewController!, animated: true, completion: nil)
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

    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        var callBack: SPTAuthCallback = { (error: NSError!, session: SPTSession!) -> () in
            if error != nil {
                println("oh noes!")
            }
            var player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
            player?.loginWithSession(session, callback: { (error: NSError!) in
                if error != nil {
                    println("oh shit")
                } else {
                    println("spotify player logged in")
                    player?.playbackDelegate = self.playbackController
                    player?.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
                    self.playbackController?.dismissViewControllerAnimated(true, completion: nil)
                    self.playbackController?.player = player
                }
                
            })

        }
        
        if SPTAuth.defaultInstance().canHandleURL(url) {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: callBack)
            return true;
        }
        
        return false
    }

}

