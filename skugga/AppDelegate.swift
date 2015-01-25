//
//  AppDelegate.swift
//  skugga
//
//  Created by arnaud on 25/01/2015.
//
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSDraggingDestination {

    @IBOutlet weak var window: NSWindow!

    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        // Insert code here to initialize your application
        initStatusItem();
    }

    func applicationWillTerminate(aNotification: NSNotification)
    {
        // Insert code here to tear down your application
    }

    // MARK: NSDraggingDestination protocol methods
    func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation
    {
        return NSDragOperation.Copy;
    }
    
    func performDragOperation(sender: NSDraggingInfo) -> Bool
    {
        return true;
    }
    
    // MARK: Statusbar Icon
    private func initStatusItem()
    {
        if (statusItem == nil)
        {
            statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1); // Linker error : Use -1 instead of NSVariableStatusItemLength
            var iconImage: NSImage! = NSImage(named: "Menubar_Idle");
            iconImage.setTemplate(true);
            statusItem.image = iconImage;
            var button = statusItem.button;
            button?.window?.registerForDraggedTypes([NSURLPboardType]);
            button?.window?.delegate = self;
        }
    }
}

