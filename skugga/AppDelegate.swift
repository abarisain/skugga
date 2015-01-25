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

    @IBOutlet weak var popover: NSPopover!
    
    @IBOutlet weak var statusItemMenu: NSMenu!
    
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        // Insert code here to initialize your application
        initStatusItem();
        
        // Make the popover close when the user clicks outside of it
        popover.behavior = NSPopoverBehavior.Transient;
        
        // Set this if we want to force a light popover appearance
        //popover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
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
            // Using a template lets Mac OS X show it properly in light and dark mode !
            iconImage.setTemplate(true);
            statusItem.image = iconImage;
            //statusItem.menu = statusItemMenu;
            var button = statusItem.button;
            button?.target = self;
            button?.action = "toggleMainPopover";
            button?.sendActionOn((Int)(NSEventMask.LeftMouseUpMask.rawValue | NSEventMask.RightMouseUpMask.rawValue));
            button?.window?.registerForDraggedTypes([NSURLPboardType]);
            button?.window?.delegate = self;
        }
    }
    
    func toggleMainPopover()
    {
        if (popover.shown)
        {
            popover.performClose(self);
        }
        else
        {
            popover.showRelativeToRect((statusItem.button?.bounds)!,
                ofView: statusItem.button!,
                preferredEdge: NSMaxYEdge);
        }
    }
    
    @IBAction func quitApp(sender: AnyObject)
    {
    }
}

