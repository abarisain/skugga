//
//  AppDelegate.swift
//  skugga
//
//  Created by arnaud on 25/01/2015.
//
//

import Cocoa

public struct ClientConsts
{
    static let DEBUG_URL = "http://localhost:9000/"
    static let CLIENT_ERROR_DOMAIN = "SkuggaClientError"
}

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
        var pasteboard = sender.draggingPasteboard();
        if (pasteboard.types?.filter({$0 as NSString == NSURLPboardType}).count > 0)
        {
            var file = NSURL(fromPasteboard: pasteboard);
            UploadClient().uploadFile(file!, progress: { (bytesSent, bytesToSend) -> Void in
                    NSLog("%l / %l", bytesSent, bytesToSend);
                }, success: { ([NSObject : AnyObject]) -> Void in
                    NSLog("success");
                }, failure: { (error: NSError) -> Void in
                    NSLog("failure %@", error);
                }
            );
        }
        
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
            button?.action = "statusButtonPressed";
            button?.sendActionOn((Int)(NSEventMask.LeftMouseUpMask.rawValue | NSEventMask.RightMouseUpMask.rawValue));
            button?.window?.registerForDraggedTypes([NSURLPboardType]);
            button?.window?.delegate = self;
        }
    }
    
    func statusButtonPressed()
    {
        // Check if Alt (option) is pressed
        if (((NSApp.currentEvent??.modifierFlags)! & NSEventModifierFlags.AlternateKeyMask) != nil)
        {
            showMenuFromView(statusItem.button!, window: (statusItem.button?.window)!);
        }
        else
        {
            toggleMainPopover();
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
    
    // MARK: Menu Actions
    
    func showMenuFromView(view: NSView, window: NSWindow)
    {
        var origin = view.superview?.convertPoint(NSMakePoint(view.frame.origin.x, view.frame.origin.y), toView: nil);
        
        var event = NSEvent.mouseEventWithType(NSEventType.LeftMouseUp, location:origin!, modifierFlags: NSEventModifierFlags.allZeros, timestamp: NSTimeIntervalSince1970, windowNumber: window.windowNumber, context: nil, eventNumber: 0, clickCount: 0, pressure: 0.1);
        NSMenu.popUpContextMenu(statusItemMenu, withEvent: event!, forView: statusItem.button!);
    }
    
    @IBAction func quitApp(sender: AnyObject)
    {
        NSApplication.sharedApplication().terminate(nil);
    }
}

