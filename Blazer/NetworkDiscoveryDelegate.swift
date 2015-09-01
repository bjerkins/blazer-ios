//
//  NetworkDiscoveryDelegate.swift
//  Blazer
//
//  Created by Bjarki Sorens on 01/09/15.
//  Copyright (c) 2015 someNerves. All rights reserved.
//

import Foundation

class NetworkServiceDelegate : NSObject, NSNetServiceDelegate {
    
    func netServiceWillResolve(sender: NSNetService) {
        println("netServiceWillResolve:\(sender)");
        println("addresses: \(sender.addresses)")
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        println("netServiceDidNotResolve:\(sender)");
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        println("netServiceDidResolve:\(sender)");
    }
    
    func netServiceDidStop(sender: NSNetService) {
        println("netServiceDidStopService:\(sender)");
    }
}

class NetworkDiscoveryDelegate : NSObject, NSNetServiceBrowserDelegate {
    
    var serviceDelegate: NetworkServiceDelegate?
    var services: [NSNetService]?
    
    func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        println("starting search")
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
        didFindService netService: NSNetService,
        moreComing moreServicesComing: Bool) {
            
            if self.services == nil {
                self.services = []
            }
            
            self.serviceDelegate = NetworkServiceDelegate()
            
            netService.delegate = self.serviceDelegate
            
            netService.resolveWithTimeout(5)
            
            self.services?.append(netService)
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
        didRemoveService netService: NSNetService,
        moreComing moreServicesComing: Bool) {
            println("netServiceDidRemoveService")
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
        didNotSearch errorInfo: [NSObject : AnyObject]) {
            println("netServiceDidNotSearch")
    }
    
    func netServiceBrowserDidStopSearch(netServiceBrowser: NSNetServiceBrowser) {
        println("netServiceDidStopSearch")
    }
    
}