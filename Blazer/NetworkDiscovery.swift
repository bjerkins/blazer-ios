//
//  NetworkDiscovery.swift
//  Blazer
//
//  Created by Bjarki Sorens on 01/09/15.
//  Copyright (c) 2015 someNerves. All rights reserved.
//

import Foundation


class NetworkDiscovery: NSObject {
    
    var netServiceBrowser: NSNetServiceBrowser?
    var networkServiceBrowserDelegate:NetworkServiceBrowserDelegate?
    var discovereNnetworkAddress: String?
    
    override init() {
        self.netServiceBrowser = NSNetServiceBrowser()
        self.networkServiceBrowserDelegate = NetworkServiceBrowserDelegate()
        self.netServiceBrowser?.delegate = self.networkServiceBrowserDelegate
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "networkDiscovered:", name: "networkFound", object: nil)
    }
    
    func networkDiscovered(notification: NSNotification) {
        var address = notification.userInfo!["address"] as! String
        var server = notification.userInfo!["serverName"] as! String
        
        println("server: \(server) - address: \(address)")
    }
    
    func discover() {
        self.netServiceBrowser!.searchForServicesOfType("_http._tcp.", inDomain: "")
    }
}