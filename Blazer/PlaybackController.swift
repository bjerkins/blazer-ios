//
//  FirstViewController.swift
//  Blazer
//
//  Created by Bjarki Sorens on 27/08/15.
//  Copyright (c) 2015 someNerves. All rights reserved.
//

import UIKit
import Socket_IO_Client_Swift
import SwiftyJSON

class PlaybackController:
    UIViewController,
    SpotifyLoginDelegate,
    SPTAudioStreamingDelegate,
    SPTAudioStreamingPlaybackDelegate {
    
    let socket = SocketIOClient(socketURL: "10.1.16.15:8080")
    let clientId = "68dadb65de254d06b58afe049b562d45"
    let callbackURL = "blazer://callback"
    let scopes = [
        SPTAuthUserReadPrivateScope,
        SPTAuthUserReadEmailScope,
        SPTAuthStreamingScope
    ]
    
    var spotifyAuthentication = SPTAuth.defaultInstance()
    var player: SPTAudioStreamingController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        spotifyAuthentication.clientID = self.clientId
        spotifyAuthentication.redirectURL = NSURL(string: self.callbackURL)
        spotifyAuthentication.requestedScopes = self.scopes
        
        self.addSocketHandlers()
        self.socket.connect()
        self.socket.nsp = "client"
        self.socket.joinNamespace()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if spotifyAuthentication.session == nil { // no token received
            
        } else if spotifyAuthentication.session.isValid() { // we have token

        } else { // token expired
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: IBActions
    
    @IBAction func login(sender: UIButton) {
        UIApplication.sharedApplication().openURL(SPTAuth.defaultInstance().loginURL)
    }
    
    
    // MARK: SpotifyLoginDelegate methods
    
    func spotifySessionInitialized(session: SPTSession) {
        
        if self.player == nil { // instantiate player
            self.player = SPTAudioStreamingController(clientId: spotifyAuthentication.clientID)
            self.player?.playbackDelegate = self
            self.player?.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
        }
        
        // login the player
        self.player?.loginWithSession(session, callback: { (error: NSError!) in
            if error != nil {
                println("oh shit")
            } else {
                println("spotify player logged in")
            }

        })
    }
    
    // MARK: SPTAudioStreamingDelegate and SPTAudioStreamingPlaybackDelegate methods
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didFailToPlayTrack trackUri: NSURL!) {
        println("audio stream: failed to play track")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        println("audio stream: message received")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        println("audio stream: playback status changed")
    }
    
    // MARK: Private helper functions
    
    private func addSocketHandlers() {
        
        self.socket.on("status") {data, ack in
            println("status")
        }
        
        self.socket.on("playtrack") {data, ack in
            println("PLAY TRACK")
            let json = JSON(data![0])
            let track = json["track"].string
            
            var auth = SPTAuth.defaultInstance()
            
            var trackRequest = SPTTrack.createRequestForTrack(
                NSURL(string: track!),
                withAccessToken: auth.session.accessToken,
                market: nil,
                error: nil
            )
            
            SPTRequest.sharedHandler().performRequest(trackRequest, callback: { (error: NSError!, response: NSURLResponse!, data: NSData!) in
                
                if error != nil {
                    println("oh noes")
                }
                
                var track = SPTTrack(fromData: data, withResponse: response, error: nil)
                
                if error != nil {
                    println("oh noes")
                }
                
                self.player?.playURIs([track.uri], fromIndex: 0, callback: nil)
            })
        }
        
        self.socket.on("connect") {data, ack in
            println("socket connected")
        }

    }
}

