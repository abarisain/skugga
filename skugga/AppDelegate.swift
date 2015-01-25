//
//  AppDelegate.swift
//  skugga
//
//  Created by arnaud on 25/01/2015.
//
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1); // Linker error : Use -1 instead of NSVariableStatusItemLength
        var iconImage: NSImage! = NSImage(named: "Menubar_Idle");
        iconImage.setTemplate(true);
        statusItem.image = iconImage;

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

