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
    var loginViewController: UIViewController?
    var playbackController: PlaybackController?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        self.playbackController = storyBoard.instantiateInitialViewController() as? PlaybackController
        self.loginViewController = storyBoard.instantiateViewControllerWithIdentifier("LoginViewController") as UIViewController
        
        self.window?.rootViewController = playbackController
        self.window?.makeKeyAndVisible()
        
        // check spotify auth token
        let auth = SPTAuth.defaultInstance()
        
        if auth.session == nil || !auth.session.isValid() { // no token received
            self.playbackController?.presentViewController(self.loginViewController!, animated: true, completion: nil)
        }
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        let callBack: SPTAuthCallback = { (error: NSError!, session: SPTSession!) -> () in
            if error != nil {
                print("oh noes!")
            }
            
            // set session and dismiss login view
            self.playbackController?.spotifySession = session
            self.playbackController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if SPTAuth.defaultInstance().canHandleURL(url) {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: callBack)
            return true;
        }
        
        return false
    }

}

