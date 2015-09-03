//
//  NetworkDiscovery.swift
//  Blazer
//
//  Created by Bjarki Sorens on 01/09/15.
//  Copyright (c) 2015 someNerves. All rights reserved.
//

import Foundation

protocol NetworkFoundDelegate {
    func didFindNetwork(network: AvailableNetwork)
}

class NetworkDiscovery: NSObject {
    
    var netServiceBrowser: NSNetServiceBrowser?
    var networkServiceBrowserDelegate:NetworkServiceBrowserDelegate?
    var discovereNnetworkAddress: String?
    var delegate: NetworkFoundDelegate?
    
    override init() {
        self.netServiceBrowser = NSNetServiceBrowser()
        self.networkServiceBrowserDelegate = NetworkServiceBrowserDelegate()
        self.netServiceBrowser?.delegate = self.networkServiceBrowserDelegate
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "networkDiscovered:", name: "networkFound", object: nil)
    }
    
    func networkDiscovered(notification: NSNotification) {
        var availableNetwork = AvailableNetwork()
        availableNetwork.address = notification.userInfo!["address"] as? String
        availableNetwork.name = notification.userInfo!["serverName"] as? String
        self.delegate!.didFindNetwork(availableNetwork)
    }
    
    func discover() {
        self.netServiceBrowser!.searchForServicesOfType("_http._tcp.", inDomain: "")
    }
}