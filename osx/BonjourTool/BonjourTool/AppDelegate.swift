//
//  AppDelegate.swift
//  BonjourTool
//
//  Created by Jaanus Kase on 08.05.15.
//  Copyright (c) 2015 Jaanus Kase. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var windowController: WindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("applicationDidFinishLaunching")
    
        windowController = WindowController(windowNibName: NSNib.Name("WindowController"))
        windowController?.showWindow(self)
    }

    func applicationWillTerminate(aNotification: Notification) {
        // Insert code here to tear down your application
    }

//    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
//        windowController?.showWindow(self)
//        return false
//    }
}

