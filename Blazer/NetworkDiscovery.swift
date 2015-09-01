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
    var netServiceBrowserDelegate:NetworkDiscoveryDelegate?
    
    override init() {
        self.netServiceBrowser = NSNetServiceBrowser()
        self.netServiceBrowserDelegate = NetworkDiscoveryDelegate()
        self.netServiceBrowser?.delegate = netServiceBrowserDelegate
    }
    
    func discover() {
        self.netServiceBrowser!.searchForServicesOfType("_http._tcp.", inDomain: "")
    }
    
//    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
//        println("found service \(aNetService)");
//        aNetService.delegate = self
//        aNetService.resolveWithTimeout(1)
//        let runloop = NSRunLoop.currentRunLoop()
//        runloop.run()
//    }
    
    private func translateSockAddress(sender: NSNetService) {
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
    
    
}