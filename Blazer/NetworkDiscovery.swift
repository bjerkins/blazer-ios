//
//  NetworkDiscovery.swift
//  Blazer
//
//  Created by Bjarki Sorens on 01/09/15.
//  Copyright (c) 2015 someNerves. All rights reserved.
//

import Foundation

class NetworkDiscovery: NSObject, NSNetServiceBrowserDelegate, NSNetServiceDelegate {
    
    var netServiceBrowser: NSNetServiceBrowser?
    
    override init() {
        self.netServiceBrowser = NSNetServiceBrowser()
        super.init()
        self.netServiceBrowser?.delegate = self
    }
    
    func discover() {
        self.netServiceBrowser?.searchForServicesOfType("_http._tcp.", inDomain: "")
        let runloop = NSRunLoop.currentRunLoop()
        runloop.run()
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        println(domainString)
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        println("found service \(aNetService)");
        aNetService.delegate = self
        aNetService.resolveWithTimeout(1)
        let runloop = NSRunLoop.currentRunLoop()
        runloop.run()
    }
    
    func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        println("starting search but wtf")
    }
    
    func netServiceBrowserDidStopSearch(aNetServiceBrowser: NSNetServiceBrowser) {
        println("stopped searching")
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didNotSearch errorDict: [NSObject : AnyObject]) {
        println("did not search")
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService aNetService: NSNetService, moreComing: Bool) {
        println("did remove service")
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        println("did resolve \(sender.addresses)")
        
        if let data: AnyObject = sender.addresses?.first {
            var storage = sockaddr_storage()
            data.getBytes(&storage, length: sizeof(sockaddr_storage))
            
            if Int32(storage.ss_family) == AF_INET {
                let addr4 = withUnsafePointer(&storage) { UnsafePointer<sockaddr_in>($0).memory }
                
                println(String(CString: inet_ntoa(addr4.sin_addr), encoding: NSASCIIStringEncoding))
                println(sender.port)
            }
        }
    }
    
    func netServiceWillResolve(sender: NSNetService) {
        println("hoping to resolve this \(sender)")
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        println("did not resolve \(sender) because \(errorDict)")
    }
    
    
    
}