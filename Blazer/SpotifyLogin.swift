//
//  SpotifyLogin.swift
//  Blazer
//
//  Created by Bjarki Sorens on 29/08/15.
//  Copyright (c) 2015 someNerves. All rights reserved.
//

import Foundation

protocol SpotifyLoginDelegate {
    
    func spotifySessionInitialized(session: SPTSession)
    
}