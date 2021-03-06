//
//  NetworkDiscoveryDelegate.swift
//  Blazer
//
//  Created by Bjarki Sorens on 01/09/15.
//  Copyright (c) 2015 someNerves. All rights reserved.
//

import Foundation

class NetworkServiceDelegate : NSObject, NSNetServiceDelegate {
    
    func netServiceWillResolve(sender: NSNetService) {}
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        print("netServiceDidNotResolve:\(sender)");
    }
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        let address = self.translateSockAddress(sender)
        let userInfo = [
            "address": "http://\(address!)",
            "serverName": sender.name
        ]
        
        NSNotificationCenter.defaultCenter().postNotificationName("networkFound", object: nil, userInfo: userInfo)
    }
    
    func netServiceDidStop(sender: NSNetService) {}
    
    private func translateSockAddress(sender: NSNetService) -> String? {
        if let data: AnyObject = sender.addresses?.first {
            var storage = sockaddr_storage()
            data.getBytes(&storage, length: sizeof(sockaddr_storage))
            
            if Int32(storage.ss_family) == AF_INET {
                let addr4 = withUnsafePointer(&storage) { UnsafePointer<sockaddr_in>($0).memory }
                
                let address = String(CString: inet_ntoa(addr4.sin_addr), encoding: NSASCIIStringEncoding)
                let port = sender.port
                
                return "\(address!):\(port)"
            }
        }
        
        return nil
    }
}

class NetworkServiceBrowserDelegate : NSObject, NSNetServiceBrowserDelegate {
    
    var serviceDelegate: NetworkServiceDelegate?
    var services: [NSNetService]?
    
    func netServiceBrowserWillSearch(aNetServiceBrowser: NSNetServiceBrowser) {}
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser, didFindService netService: NSNetService,
        moreComing moreServicesComing: Bool) {
            
            if self.services == nil {
                self.services = []
            }
            
            // initialize the service delegate
            self.serviceDelegate = NetworkServiceDelegate()
            
            // set the netservice delgate and resolve it
            netService.delegate = self.serviceDelegate
            netService.resolveWithTimeout(5)
            
            self.services?.append(netService)
    }
    
    func netServiceBrowser(netServiceBrowser: NSNetServiceBrowser,
        didNotSearch errorInfo: [String : NSNumber]) {
            print("netServiceDidNotSearch")
    }
    
    func netServiceBrowserDidStopSearch(netServiceBrowser: NSNetServiceBrowser) {
        print("netServiceDidStopSearch")
    }
    
}