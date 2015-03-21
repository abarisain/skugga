//
//  AppDelegate.swift
//  skugga
//
//  Created by arnaud on 25/01/2015.
//
//

import Cocoa

let statusIconHeight: CGFloat = 18.0
let statusIconWidth: CGFloat = 24.0

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSDraggingDestination, NSUserNotificationCenterDelegate, AdvancedUploadViewDelegate {
    
    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var popover: NSPopover!
    
    @IBOutlet weak var statusItemMenu: NSMenu!
    
    @IBOutlet weak var settingsWindow: SettingsWindow!
    
    // TODO : Maybe make a class that controls the statusbar icon
    var statusItem: NSStatusItem!
    
    var statusNormalImage: NSImage! // The smiling one ! Yeah it could be "I'm finished !" but I like it smiling all the time

    var statusEmptyImage: NSImage!
    
    var statusFinishedImage: NSImage!
    
    var statusProgressImage: NSImage! //Programatically drawn
    
    var notificationCenter: NSUserNotificationCenter!
    
    var shownAdvancedUploadPopover: NSPopover?

    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        
        // Insert code here to initialize your application
        initStatusItem()
        
        // Make the popover close when the user clicks outside of it
        popover.behavior = NSPopoverBehavior.Transient
        
        // Set this if we want to force a light popover appearance
        //popover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        
        notificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        notificationCenter.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "uploadFromNotification",
            name: NSUserDefaultsDidChangeNotification,
            object: RMSharedUserDefaults.standardUserDefaults())
        
        refreshFileList()
    }

    func applicationWillTerminate(aNotification: NSNotification)
    {
        // Insert code here to tear down your application
    }

    // MARK: NSDraggingDestination protocol methods
    func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation
    {
        return NSDragOperation.Copy
    }
    
    func performDragOperation(sender: NSDraggingInfo) -> Bool
    {
        var pasteboard = sender.draggingPasteboard()
        if (pasteboard.types?.filter({$0 as! String == NSURLPboardType}).count > 0)
        {
            var file = NSURL(fromPasteboard: pasteboard)
            // Check if Alt (option) is pressed
            if (((NSApp.currentEvent??.modifierFlags)! & NSEventModifierFlags.AlternateKeyMask) != nil)
            {
                shownAdvancedUploadPopover?.performClose(self)
                shownAdvancedUploadPopover = nil
                showAdvancedUploadPopoverForURL(file!)
            }
            else
            {
                uploadURL(file!)
            }
        }
        
        return true
    }
    
    func refreshFileList()
    {
        FileListClient().getFileList({ (files: [RemoteFile]) -> () in
            if let controller = self.popover.contentViewController as? PopoverViewController
            {
                controller.refreshWithRemoteFiles(files)
            }
        }, failure: { (error: NSError) -> () in
            NSLog("Error while refreshing file list %@", error)
        })
    }
    
    func uploadFromNotification()
    {
        var defaults = RMSharedUserDefaults.standardUserDefaults()
        if let targetURL = defaults.URLForKey("shareExtensionURL")
        {
            defaults.removeObjectForKey("shareExtensionURL")
            uploadURL(targetURL)
        }
    }
    
    private func uploadURL(url: NSURL)
    {
        UploadClient().uploadFile(url, progress: { (bytesSent:Int64, bytesToSend:Int64) -> Void in
            self.drawStatusIconForProgress(Float(Double(bytesSent) / Double(bytesToSend)))
            }, success: { (data: [NSObject: AnyObject]) -> Void in
                var url = data["name"] as! String
                url = Configuration.endpoint + url
                
                let pasteboard = NSPasteboard.generalPasteboard()
                pasteboard.clearContents()
                pasteboard.setString(url, forType: NSStringPboardType)
                
                NSLog("Upload succeeded ! \(url)")
                
                let notification = NSUserNotification()
                notification.title = "Skugga"
                notification.subtitle = "File uploaded : \(url)"
                notification.deliveryDate = NSDate()
                notification.soundName = "Glass.aiff"
                notification.userInfo = ["url": url]
                
                // Private API to have buttons on non-alert notifications
                // I don't get why Apple doesn't want us to have buttons on notifications that go away, but keeps
                // that for iTunes and Mail.app
                notification.setValue(true, forKey: "_showsButtons")
                
                notification.actionButtonTitle = "Open"
                
                self.notificationCenter.scheduleNotification(notification)
                
                self.setNormalStatusIcon()
                
                self.refreshFileList()
                
            }, failure: { (error: NSError) -> Void in
                NSLog("Upload failed ! \(error)")
                
                var errorSubtitle = "Error while uploading file"
                
                if let statusCode = error.userInfo?["statusCode"] as? Int
                {
                    errorSubtitle += " (\(statusCode))"
                }
                
                let notification = NSUserNotification()
                notification.title = "Skugga"
                notification.subtitle = errorSubtitle
                notification.deliveryDate = NSDate()
                notification.soundName = "Glass.aiff"
                
                self.notificationCenter.scheduleNotification(notification)
                
                self.setNormalStatusIcon()
            }
        )
    }
    
    // MARK: Statusbar Icon
    private func initStatusItem()
    {
        if (statusItem == nil)
        {
            statusNormalImage = NSImage(named: "Menubar_Idle")
            statusEmptyImage = NSImage(named: "Menubar_Empty")
            statusFinishedImage = NSImage(named: "Menubar_Finished")
            statusProgressImage = NSImage(size: NSSize(width: 24.0, height: 18.0))
            
            // Using templates lets OS X show them properly in light and dark mode !
            
            statusNormalImage.setTemplate(true)
            statusEmptyImage.setTemplate(true)
            statusFinishedImage.setTemplate(true)
            statusProgressImage.setTemplate(true)
            
            
            statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1); // Linker error : Use -1 instead of NSVariableStatusItemLength
            statusItem.image = statusNormalImage
            //statusItem.menu = statusItemMenu
            var button = statusItem.button
            button?.target = self
            button?.action = "statusButtonPressed"
            button?.sendActionOn((Int)(NSEventMask.LeftMouseUpMask.rawValue | NSEventMask.RightMouseUpMask.rawValue))
            button?.window?.registerForDraggedTypes([NSURLPboardType])
            button?.window?.delegate = self
        }
    }
    
    // Progress should be between 0 and 1
    func drawStatusIconForProgress(progress: Float)
    {
        // FIXME : Use GCD ?
        objc_sync_enter(statusProgressImage)
        
        // Clean the progress image, draw the two clipped images (normal and progress) according to percentage
        // then, set that as menubar icon.
        statusProgressImage.lockFocus()
        
        // Round progress to the first decimal, otherwise the drawing gets funky
        var roundedProgress = round(progress * 10)/10
        
        NSGraphicsContext.saveGraphicsState()
        NSColor.clearColor().set()
        NSGraphicsContext.currentContext()?.compositingOperation = .CompositeClear
        NSBezierPath.fillRect(NSRect(x: 0, y: 0, width: statusIconWidth, height: statusIconHeight))
        NSGraphicsContext.restoreGraphicsState()
        
        var progressPath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: (statusIconWidth * CGFloat(roundedProgress)), height: statusIconHeight))
        
        var emptyPath = NSBezierPath(rect: NSRect(x: (statusIconWidth * CGFloat(roundedProgress)), y: 0, width: statusIconWidth - (statusIconWidth * CGFloat(roundedProgress)), height: statusIconHeight))

        NSGraphicsContext.saveGraphicsState()
        progressPath.addClip()
        statusFinishedImage.drawInRect(NSRect(x: 0, y: 0, width: statusIconWidth, height: statusIconHeight),
            fromRect: NSZeroRect,
            operation: .CompositeSourceOver,
            fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        
        NSGraphicsContext.saveGraphicsState()
        emptyPath.addClip()
        statusEmptyImage.drawInRect(NSRect(x: 0, y: 0, width: statusIconWidth, height: statusIconHeight),
            fromRect: NSZeroRect,
            operation: .CompositeSourceOver,
            fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        
        statusProgressImage.unlockFocus()
        
        statusItem.image = statusProgressImage
        
        objc_sync_exit(statusProgressImage)
    }
    
    func setNormalStatusIcon()
    {
        statusItem.image = statusNormalImage
    }
    
    func statusButtonPressed()
    {
        // Check if Alt (option) is pressed
        if (((NSApp.currentEvent??.modifierFlags)! & NSEventModifierFlags.AlternateKeyMask) != nil)
        {
            showMenuFromView(statusItem.button!, window: (statusItem.button?.window)!)
        }
        else
        {
            toggleMainPopover()
        }
    }
    
    func toggleMainPopover()
    {
        if (popover.shown)
        {
            popover.performClose(self)
        }
        else
        {
            (popover.contentViewController as! PopoverViewController).reloadData()
            popover.showRelativeToRect((statusItem.button?.bounds)!,
                ofView: statusItem.button!,
                preferredEdge: NSMaxYEdge)
        }
    }
    
    func showAdvancedUploadPopoverForURL(url: NSURL)
    {
        if shownAdvancedUploadPopover != nil
        {
            return
        }
        
        var objects : NSArray?
        let nib = NSBundle.mainBundle().loadNibNamed("AdvancedUploadPopover", owner: self, topLevelObjects: &objects)
        if let objects = objects as? [AnyObject]
        {
            if let popover = objects.filter({$0 is NSPopover}).first as? NSPopover
            {
                if let popoverController = popover.contentViewController as? AdvancedUploadViewController
                {
                    shownAdvancedUploadPopover = popover
                    
                    popoverController.fileToUpload = url
                    popoverController.delegate = self
                    
                    popover.showRelativeToRect((statusItem.button?.bounds)!,
                        ofView: statusItem.button!,
                        preferredEdge: NSMaxYEdge)
                }
            }
        }
    }
    
    // MARK: Menu Actions
    
    func showMenuFromView(view: NSView, window: NSWindow)
    {
        var origin = view.superview?.convertPoint(NSMakePoint(view.frame.origin.x, view.frame.origin.y), toView: nil)
        
        var event = NSEvent.mouseEventWithType(NSEventType.LeftMouseUp, location:origin!, modifierFlags: NSEventModifierFlags.allZeros, timestamp: NSTimeIntervalSince1970, windowNumber: window.windowNumber, context: nil, eventNumber: 0, clickCount: 0, pressure: 0.1)
        NSMenu.popUpContextMenu(statusItemMenu, withEvent: event!, forView: statusItem.button!)
    }
    
    @IBAction func quitApp(sender: AnyObject)
    {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    // MARK : NSUserNotificationSenderDelegate methods
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool
    {
        return true
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification)
    {
        if (notification.activationType == .ActionButtonClicked)
        {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: (notification.userInfo!["url"] as! NSString) as String)!)
        }
    }
    
    // MARK : AdvancedUploadViewDelegate methods
    
    func uploadURL(url: NSURL, filename: String, tags: String, ttl: String?, retina: Bool)
    {
        
    }
    
    func dismissAdvancedUploadPopover()
    {
        shownAdvancedUploadPopover?.performClose(self)
        shownAdvancedUploadPopover = nil
    }
    
    // MARK : Menu methods
    
    @IBAction func menuUploadFromDisk(sender: AnyObject)
    {
        var openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        
        var clickedButton = openPanel.runModal()
        
        if (clickedButton == NSFileHandlingPanelOKButton)
        {
            if let url = openPanel.URLs.first as? NSURL
            {
                uploadURL(url)
            }
            else
            {
                NSLog("No url found from NSOpenPanel, aborting.")
            }
        }
    }
    
    @IBAction func menuPreferences(sender: AnyObject)
    {
        if (!settingsWindow.visible)
        {
            settingsWindow.refreshFields()
        }
        settingsWindow.makeKeyAndOrderFront(nil)
    }
    
    @IBAction func menuRefreshFileList(sender: AnyObject)
    {
        refreshFileList()
    }
}

