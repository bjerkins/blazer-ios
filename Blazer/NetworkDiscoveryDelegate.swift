//
//  NetworkDiscoveryDelegate.swift
//  Blazer
//
//  Created by Bjarki Sorens on 01/09/15.
//  Copyright (c) 2015 someNerves. All rights reserved.
//

import Foundation

class Fleh : NSObject, NSNetServiceDelegate {
    
    
    func netServiceWillResolve(sender: NSNetService) {
        println("netServiceWillResolve:\(sender)");
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
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
        didFindDomain domainName: String,
        moreComing moreDomainsComing: Bool) {
            println("netServiceDidFindDomain")
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
        didRemoveDomain domainName: String,
        moreComing moreDomainsComing: Bool) {
            println("netServiceDidRemoveDomain")
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
        didFindService netService: NSNetService,
        moreComing moreServicesComing: Bool) {
            println("netServiceDidFindService")
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