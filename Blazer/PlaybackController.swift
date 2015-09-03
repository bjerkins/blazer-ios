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
    SPTAudioStreamingPlaybackDelegate,
    UIScrollViewDelegate,
    NetworkFoundDelegate,
    UIGestureRecognizerDelegate {
    
    // MARK: Properties
    
    var socket: SocketIOClient?
    var spotifyAuthentication = SPTAuth.defaultInstance()
    var player: SPTAudioStreamingController?
    var networkDiscovery: NetworkDiscovery?
    var availableNetworks: [AvailableNetwork]?
    var connectedNetworkLabel: NetworkLabel?
    var session: SPTSession?
    var shit: String?
    

    // MARK: outlets
    
    @IBOutlet weak var nowPlayingHeadingLabel: UILabel!
    @IBOutlet weak var serverNameHeading: UILabel!
    @IBOutlet weak var availableNetworksScrollView: UIScrollView!
    @IBOutlet weak var availableNetworksPageControl: UIPageControl!
    @IBOutlet weak var availableNetworksSearchingLabel: UILabel!

    // MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.availableNetworks = []
        
        self.networkDiscovery = NetworkDiscovery()
        self.networkDiscovery?.delegate = self
        self.networkDiscovery?.discover()
        
        self.availableNetworksScrollView.delegate = self
    }
    
    // MARK: NetworkFound Delegate
    
    func didFindNetwork(network: AvailableNetwork) {
        self.availableNetworks?.append(network)
        self.availableNetworksPageControl.numberOfPages = self.availableNetworks!.count
        self.availableNetworksSearchingLabel.hidden = true
        self.setupScrollViewForAvailableNetworks()
    }
    

    // MARK: ScrollView Delegates
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
        var currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.availableNetworksPageControl.currentPage = Int(currentPage);
    }
    
    
    // MARK: SpotifyLoginDelegate methods
    
    
    func spotifySessionInitialized(session: SPTSession) {
        
        self.session = session
        self.shit = "Yeah"
        
        self.player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
        self.player?.playbackDelegate = self
        self.player?.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
        
        // login the player
        self.player?.loginWithSession(session, callback: { (error: NSError!) in
            if error != nil {
                println("oh shit")
            } else {
                println("spotify player logged in")
                self.player?.setIsPlaying(false, callback: nil)
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

    private func connectToSocket() {
        var network = self.availableNetworks![self.availableNetworksPageControl.currentPage]
        self.socket = SocketIOClient(socketURL: network.address!)
        self.setupSocketHandlers()
        self.socket!.connect()
        self.socket!.nsp = "client"
        self.socket!.joinNamespace()
    }
    
    private func setupSocketHandlers() {
        
        self.socket!.on("playtrack") {data, ack in
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
        
        self.socket!.on("connect") {data, ack in
            self.serverNameHeading.text = "CONNECTED TO"
            self.connectedNetworkLabel?.setConnectedColor()
        }
        
        self.socket!.on("disconnect") {data, ack in
            self.connectedNetworkLabel?.setDisconnectedColor()
            self.connectedNetworkLabel = nil
            self.serverNameHeading.text = "CONNECT TO"
        }
        
        self.socket!.on("error") {data, ack in
            self.serverNameHeading.text = "CONNECT TO"
        }
    }
    
    private func setupScrollViewForAvailableNetworks() {
        
        var numberOfNetworks = CGFloat(self.availableNetworks!.count)
        
        let scrollViewWidth:CGFloat = self.availableNetworksScrollView.frame.width
        let scrollViewHeight:CGFloat = self.availableNetworksScrollView.frame.height
        
        for (index, network) in enumerate(self.availableNetworks!) {
            var label = NetworkLabel(frame: CGRectMake(CGFloat(index) * scrollViewWidth, CGFloat(index), scrollViewWidth, scrollViewHeight))
            label.text = network.name!.uppercaseString
            let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("networkLabelTapped:"))
            label.addGestureRecognizer(tapRecognizer)
            
            self.availableNetworksScrollView.addSubview(label)
        }
        
        self.availableNetworksScrollView.contentSize = CGSizeMake(numberOfNetworks * scrollViewWidth, scrollViewHeight)
        
        self.availableNetworksScrollView.hidden = false
    }
    
    func networkLabelTapped(sender: UITapGestureRecognizer) {
        var label = sender.view as? NetworkLabel
        if self.connectedNetworkLabel == label {
            self.socket?.disconnect(fast: false)
        } else {
            self.connectedNetworkLabel = sender.view as? NetworkLabel
            self.connectedNetworkLabel?.setConnectingColor()
            self.connectToSocket()
        }
        
    }
    
}

