//
//  FirstViewController.swift
//  Blazer
//
//  Created by Bjarki Sorens on 27/08/15.
//  Copyright (c) 2015 someNerves. All rights reserved.
//

import UIKit
import SocketIOClientSwift
import SwiftyJSON

class PlaybackController:
    UIViewController,
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
    var synched: Bool?
    
    var spotifySession: SPTSession? {
        didSet {
            spotifySessionDidSet(spotifySession!)
        }
    }
    

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
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.availableNetworksPageControl.currentPage = Int(currentPage);
    }
    
    
    // MARK: SPTAudioStreamingDelegate and SPTAudioStreamingPlaybackDelegate methods
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didFailToPlayTrack trackUri: NSURL!) {
        print("audio stream: failed to play track")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print("audio stream: message received")
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        print("audio stream: playback status changed")
        if self.synched == true || isPlaying == false {
            return
        }
        
        self.player?.setIsPlaying(false, callback: nil)
        self.socket!.emit("ready", [])
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
        print("audio stream started")
    }
    

    // MARK: Private helper functions
    
    private func spotifySessionDidSet(session: SPTSession) {
        if self.player == nil {
            self.player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID)
            self.player!.playbackDelegate = self
            self.player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
        }
        
        self.player!.loginWithSession(session, callback: { (error: NSError!) in
            if error != nil {
                print("failed to login player")
            } else {
                print("spotify player logged in")
            }
        })

    }

    private func connectToSocket() {
        let network = self.availableNetworks![self.availableNetworksPageControl.currentPage]
        let url = NSURL(string: network.address!)!
        self.socket = SocketIOClient(socketURL: url)
        self.setupSocketHandlers()
        self.socket!.connect()
        self.socket!.joinNamespace("/client")
    }
    
    private func setupSocketHandlers() {
        
        self.socket!.on("prepare:playtrack") { data, ack in
            
            self.synched = false
            
            let json = JSON(data[0])
            let track = json["track"].string
                
            let trackURI = NSURL(string: track!)
                
            self.player?.playURIs([trackURI!], fromIndex: 0, callback: {(error: NSError!) in
                if error != nil {
                    print("failed to play track")
                }
            })
        }
        
        self.socket!.on("playtrack") { data, ack in
            self.synched = true
            self.player?.setIsPlaying(true, callback: nil)
        }
        
        self.socket!.on("connect") { data, ack in
            self.serverNameHeading.text = "CONNECTED TO"
            self.connectedNetworkLabel?.setConnectedColor()
            
            self.socket!.emit("yeah")
        }
        
        self.socket!.on("disconnect") { data, ack in
            self.connectedNetworkLabel?.setDisconnectedColor()
            self.connectedNetworkLabel = nil
            self.serverNameHeading.text = "CONNECT TO"
        }
        
        self.socket!.on("error") { data, ack in
            self.serverNameHeading.text = "CONNECT TO"
            self.connectedNetworkLabel?.setDisconnectedColor()
            self.connectedNetworkLabel = nil
        }
    }
    
    private func setupScrollViewForAvailableNetworks() {
        
        let numberOfNetworks = CGFloat(self.availableNetworks!.count)
        
        let scrollViewWidth:CGFloat = self.availableNetworksScrollView.frame.width
        let scrollViewHeight:CGFloat = self.availableNetworksScrollView.frame.height
        
        for (index, network) in (self.availableNetworks!).enumerate() {
            let label = NetworkLabel(
                frame: CGRectMake(CGFloat(index) * scrollViewWidth, CGFloat(index), scrollViewWidth, scrollViewHeight)
            )
            label.text = network.name!.uppercaseString
            let tapRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(PlaybackController.networkLabelTapped(_:))
            )
            label.addGestureRecognizer(tapRecognizer)
            
            self.availableNetworksScrollView.addSubview(label)
        }
        
        self.availableNetworksScrollView.contentSize = CGSizeMake(numberOfNetworks * scrollViewWidth, scrollViewHeight)
        
        self.availableNetworksScrollView.hidden = false
    }
    
    func networkLabelTapped(sender: UITapGestureRecognizer) {
        let label = sender.view as? NetworkLabel
        if self.connectedNetworkLabel == label {
            self.socket?.disconnect()
        } else {
            self.connectedNetworkLabel = sender.view as? NetworkLabel
            self.connectedNetworkLabel?.setConnectingColor()
            self.connectToSocket()
        }
        
    }
    
}

