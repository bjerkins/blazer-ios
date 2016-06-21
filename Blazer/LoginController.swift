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
        
        self.spotifyAuthentication.clientID = self.clientId
        self.spotifyAuthentication.redirectURL = NSURL(string: self.callbackURL)
        self.spotifyAuthentication.requestedScopes = self.scopes
        self.spotifyAuthentication.sessionUserDefaultsKey = "SpotifySession"
    }

    @IBAction func login(sender: UIButton) {
        UIApplication.sharedApplication().openURL(SPTAuth.defaultInstance().loginURL)
    }

}
