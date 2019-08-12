//
//  WindowController.swift
//  BonjourTool
//
//  Created by Jaanus Kase on 08.05.15.
//  Copyright (c) 2015 Jaanus Kase. All rights reserved.
//

import Cocoa
import WebKit



class WindowController: NSWindowController, NetServiceBrowserDelegate, NetServiceDelegate {

    @IBOutlet var devicesArrayController: NSArrayController!
    let serviceBrowser = NetServiceBrowser()
    @objc dynamic var netServices: Array<NetService> = []
    let webView = WKWebView()
    @IBOutlet weak var webViewContainer: NSView!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        print("windowDidLoad")
    
        serviceBrowser.delegate = self
        serviceBrowser.searchForServices(ofType: "_jktest._tcp", inDomain: "")
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webViewContainer.addSubview(webView)
        
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[webView]-0-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: ["webView": webView])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[webView]-0-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: ["webView": webView])
        
        self.webViewContainer.addConstraints(horizontalConstraints)
        self.webViewContainer.addConstraints(verticalConstraints)
        
        devicesArrayController.addObserver(self, forKeyPath: "selectionIndexes", options: NSKeyValueObservingOptions.initial, context: nil)
    }
    
    deinit {
        devicesArrayController.removeObserver(self, forKeyPath: "selectionIndexes")
    }
    
    
    
    // MARK: - NSNetServiceBrowserDelegate
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("service browser found service: \(service). more coming: \(moreComing). service name is \(service.name)")
        
        if !netServices.contains(service) {
//        if !kAEContains(netServices, service) {
            self.willChangeValue(forKey: "netServices")
            netServices.append(service)
            self.didChangeValue(forKey: "netServices")
        }
        
        service.delegate = self
        service.resolve(withTimeout: 5)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("service browser removed service: \(service). more coming: \(moreComing)")
        if let i = netServices.index(of: service) {
            self.willChangeValue(forKey: "netServices")
            netServices.remove(at: i)
            self.didChangeValue(forKey: "netServices")
        }
    }
    
    // MARK: - NSNetServiceDelegate
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("net service did resolve address: \(sender). name is now \(sender.name)")
        // if resolved and this item is selected in the table, should do the web work
        
        let selectionIndex = devicesArrayController.selectionIndex
        if netServices[selectionIndex] == sender {
            loadContentFromNetService(netService: sender)
        }
    }
    
    func netService(sender: NetService, didNotResolve errorDict: [NSObject : AnyObject]) {
        print("service \(sender) did not resolve. error: \(errorDict)")
    }
    
    
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let selectionIndex = devicesArrayController.selectionIndex
        
        if selectionIndex == NSNotFound {
            self.webViewContainer.isHidden = true
        } else {
            self.webViewContainer.isHidden = false
            let netService = netServices[selectionIndex]
            if (netService.hostName != nil) {
                // if there is no host, displaying will happen if the host gets resolved
                loadContentFromNetService(netService: netService)
            }
        }
    }
    
    func loadContentFromNetService(netService: NetService) {
        if netService.hostName == nil { return }
        
        let url = NSURL(string: "http://\(netService.hostName!):\(netService.port)/")
        
        print("loadContentFromNetService : \(url?.absoluteString)")
        
        let urlRequest = NSURLRequest(url: url! as URL)
        webView.load(urlRequest as URLRequest)
    }
}
