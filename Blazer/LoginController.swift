//
//  LoginController.swift
//  Blazer
//
//  Created by Bjarki Sorens on 31/08/15.
//  Copyright (c) 2015 someNerves. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    
    let clientId = "68dadb65de254d06b58afe049b562d45"
    let callbackURL = "blazer://callback"
    let scopes = [
        SPTAuthUserReadPrivateScope,
        SPTAuthUserReadEmailScope,
        SPTAuthStreamingScope
    ]
    var spotifyAuthentication = SPTAuth.defaultInstance()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.spotifyAuthentication.clientID = self.clientId
        self.spotifyAuthentication.redirectURL = NSURL(string: self.callbackURL)
        self.spotifyAuthentication.requestedScopes = self.scopes
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func login(sender: UIButton) {
        UIApplication.sharedApplication().openURL(SPTAuth.defaultInstance().loginURL)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
