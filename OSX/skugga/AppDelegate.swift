//
//  AppDelegate.swift
//  skugga
//
//  Created by arnaud on 25/01/2015.
//
//

import Cocoa
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let statusIconHeight: CGFloat = 18.0
let statusIconWidth: CGFloat = 24.0

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSDraggingDestination, NSUserNotificationCenterDelegate, AdvancedUploadViewDelegate, DesktopScreenshotWatcherDelegate {
    
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
    
    var desktopScreenshotWatcher: DesktopScreenshotWatcher = DesktopScreenshotWatcher()

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        
        // Insert code here to initialize your application
        initStatusItem()
        
        // Make the popover close when the user clicks outside of it
        popover.behavior = NSPopoverBehavior.transient
        
        // Set this if we want to force a light popover appearance
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        notificationCenter = NSUserNotificationCenter.default
        notificationCenter.delegate = self
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(AppDelegate.uploadFromNotification),
            name: UserDefaults.didChangeNotification,
            object: RMSharedUserDefaults.standard)
        
        refreshFileList()
        
        //TODO : debug only, remove this
        desktopScreenshotWatcher.start()
        desktopScreenshotWatcher.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }

    // MARK: NSDraggingDestination protocol methods
    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation
    {
        return NSDragOperation.copy
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool
    {
        let pasteboard = sender.draggingPasteboard()
        if (pasteboard.types?.filter({$0 == NSURLPboardType}).count > 0)
        {
            let file = NSURL(from: pasteboard)
            // Check if Alt (option) is pressed
            if (((NSApp.currentEvent?.modifierFlags)!.intersection(NSEventModifierFlags.option)) != [])
            {
                shownAdvancedUploadPopover?.performClose(self)
                shownAdvancedUploadPopover = nil
                showAdvancedUploadPopoverForURL(file as! URL)
            }
            else
            {
                uploadURL(file as! URL)
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
        let defaults = RMSharedUserDefaults.standard
        if let targetURL = defaults.url(forKey: "shareExtensionURL")
        {
            defaults.removeObject(forKey: "shareExtensionURL")
            uploadURL(targetURL)
        }
    }
    
    fileprivate func uploadURL(_ url: URL)
    {
        do {
            let _ = try UploadClient().uploadFile(url, progress: { (bytesSent:Int64, bytesToSend:Int64) -> Void in
                self.drawStatusIconForProgress(Float(Double(bytesSent) / Double(bytesToSend)))
                }, success: { (data: [AnyHashable: Any]) -> Void in
                    var url = data["name"] as! String
                    url = Configuration.endpoint + url + Configuration.suffix
                    
                    let pasteboard = NSPasteboard.general()
                    pasteboard.clearContents()
                    pasteboard.setString(url, forType: NSStringPboardType)
                    
                    NSLog("Upload succeeded ! \(url)")
                    
                    let notification = NSUserNotification()
                    notification.title = "Skugga"
                    notification.subtitle = "File uploaded : \(url)"
                    notification.deliveryDate = NSDate() as Date
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
                    
                    if let statusCode = error.userInfo["statusCode"] as? Int
                    {
                        errorSubtitle += " (\(statusCode))"
                    }
                    
                    let notification = NSUserNotification()
                    notification.title = "Skugga"
                    notification.subtitle = errorSubtitle
                    notification.deliveryDate = NSDate() as Date
                    notification.soundName = "Glass.aiff"
                    
                    self.notificationCenter.scheduleNotification(notification)
                    
                    self.setNormalStatusIcon()
                }
            )
        } catch {
            NSLog("Upload failed! Unknown error.")
        }
    }
    
    // MARK: Statusbar Icon
    fileprivate func initStatusItem()
    {
        if (statusItem == nil)
        {
            statusNormalImage = NSImage(named: "Menubar_Idle")
            statusEmptyImage = NSImage(named: "Menubar_Empty")
            statusFinishedImage = NSImage(named: "Menubar_Finished")
            statusProgressImage = NSImage(size: NSSize(width: 24.0, height: 18.0))
            
            // Using templates lets OS X show them properly in light and dark mode !
            
            statusNormalImage.isTemplate = true
            statusEmptyImage.isTemplate = true
            statusFinishedImage.isTemplate = true
            statusProgressImage.isTemplate = true
            
            
            statusItem = NSStatusBar.system().statusItem(withLength: -1); // Linker error : Use -1 instead of NSVariableStatusItemLength
            statusItem.image = statusNormalImage
            //statusItem.menu = statusItemMenu
            let button = statusItem.button
            button?.target = self
            button?.action = #selector(statusButtonPressed)
            button?.sendAction(on: NSEventMask(rawValue: UInt64((Int)(NSEventMask.leftMouseUp.rawValue | NSEventMask.rightMouseUp.rawValue))))
            button?.window?.registerForDraggedTypes([NSURLPboardType])
            button?.window?.delegate = self
        }
    }
    
    // Progress should be between 0 and 1
    func drawStatusIconForProgress(_ progress: Float)
    {
        // FIXME : Use GCD ?
        objc_sync_enter(statusProgressImage)
        
        // Clean the progress image, draw the two clipped images (normal and progress) according to percentage
        // then, set that as menubar icon.
        statusProgressImage.lockFocus()
        
        // Round progress to the first decimal, otherwise the drawing gets funky
        let roundedProgress = round(progress * 10)/10
        
        NSGraphicsContext.saveGraphicsState()
        NSColor.clear.set()
        NSGraphicsContext.current()?.compositingOperation = .clear
        NSBezierPath.fill(NSRect(x: 0, y: 0, width: statusIconWidth, height: statusIconHeight))
        NSGraphicsContext.restoreGraphicsState()
        
        let progressPath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: (statusIconWidth * CGFloat(roundedProgress)), height: statusIconHeight))
        
        let emptyPath = NSBezierPath(rect: NSRect(x: (statusIconWidth * CGFloat(roundedProgress)), y: 0, width: statusIconWidth - (statusIconWidth * CGFloat(roundedProgress)), height: statusIconHeight))

        NSGraphicsContext.saveGraphicsState()
        progressPath.addClip()
        statusFinishedImage.draw(in: NSRect(x: 0, y: 0, width: statusIconWidth, height: statusIconHeight),
            from: NSZeroRect,
            operation: .sourceOver,
            fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        
        NSGraphicsContext.saveGraphicsState()
        emptyPath.addClip()
        statusEmptyImage.draw(in: NSRect(x: 0, y: 0, width: statusIconWidth, height: statusIconHeight),
            from: NSZeroRect,
            operation: .sourceOver,
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
        if (((NSApp.currentEvent?.modifierFlags)!.intersection(NSEventModifierFlags.option)) != [])
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
        if (popover.isShown)
        {
            popover.performClose(self)
        }
        else
        {
            (popover.contentViewController as! PopoverViewController).reloadData()
            popover.show(relativeTo: (statusItem.button?.bounds)!,
                of: statusItem.button!,
                preferredEdge: NSRectEdge.maxY)
        }
    }
    
    func showAdvancedUploadPopoverForURL(_ url: URL)
    {
        if shownAdvancedUploadPopover != nil
        {
            return
        }
        
        var objects : NSArray?
        Bundle.main.loadNibNamed("AdvancedUploadPopover", owner: self, topLevelObjects: &objects!)
        if let objects = objects as? [AnyObject]
        {
            if let popover = objects.filter({$0 is NSPopover}).first as? NSPopover
            {
                if let popoverController = popover.contentViewController as? AdvancedUploadViewController
                {
                    shownAdvancedUploadPopover = popover
                    
                    popoverController.fileToUpload = url
                    popoverController.delegate = self
                    
                    popover.show(relativeTo: (statusItem.button?.bounds)!,
                        of: statusItem.button!,
                        preferredEdge: NSRectEdge.maxY)
                }
            }
        }
    }
    
    // MARK: Menu Actions
    
    func showMenuFromView(_ view: NSView, window: NSWindow)
    {
        let origin = view.superview?.convert(NSMakePoint(view.frame.origin.x, view.frame.origin.y), to: nil)
        
        let event = NSEvent.mouseEvent(with: NSEventType.leftMouseUp, location:origin!, modifierFlags: NSEventModifierFlags(), timestamp: NSTimeIntervalSince1970, windowNumber: window.windowNumber, context: nil, eventNumber: 0, clickCount: 0, pressure: 0.1)
        NSMenu.popUpContextMenu(statusItemMenu, with: event!, for: statusItem.button!)
    }
    
    @IBAction func quitApp(_ sender: AnyObject)
    {
        NSApplication.shared().terminate(nil)
    }
    
    // MARK : NSUserNotificationSenderDelegate methods
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool
    {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification)
    {
        guard notification.activationType == .actionButtonClicked else { return }
        guard let userInfo = notification.userInfo else { return }
        
        if let url = userInfo["url"] as? String {
            guard let fileURL = URL(string: url) else { return }
            
            NSWorkspace.shared().open(fileURL)
        } else if let filePath = userInfo["filePath"] as? String {
            uploadURL(URL(fileURLWithPath: filePath))
        }
    }
    
    // MARK : AdvancedUploadViewDelegate methods
    
    func uploadURL(_ url: URL, filename: String, tags: String, ttl: String?, retina: Bool)
    {
        
    }
    
    func dismissAdvancedUploadPopover()
    {
        shownAdvancedUploadPopover?.performClose(self)
        shownAdvancedUploadPopover = nil
    }
    
    // MARK : Menu methods
    
    @IBAction func menuUploadFromDisk(_ sender: AnyObject)
    {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        
        let clickedButton = openPanel.runModal()
        
        if (clickedButton == NSFileHandlingPanelOKButton)
        {
            if let url = openPanel.urls.first
            {
                uploadURL(url)
            }
            else
            {
                NSLog("No url found from NSOpenPanel, aborting.")
            }
        }
    }
    
    @IBAction func menuPreferences(_ sender: AnyObject)
    {
        if (!settingsWindow.isVisible)
        {
            settingsWindow.refreshFields()
        }
        settingsWindow.makeKeyAndOrderFront(nil)
    }
    
    @IBAction func menuRefreshFileList(_ sender: AnyObject)
    {
        refreshFileList()
    }
    
    // MARK: Desktop Watcher methods
    func desktopScreenshotCreated(_ path: String) {
        let notification = NSUserNotification()
        notification.title = "Skugga"
        notification.subtitle = "Screenshot detected : \((path as NSString).lastPathComponent)"
        notification.deliveryDate = Date()
        notification.contentImage = NSImage.init(contentsOfFile: path)
        notification.userInfo = ["filePath": path]
        
        // Private API to have buttons on non-alert notifications
        // I don't get why Apple doesn't want us to have buttons on notifications that go away, but keeps
        // that for iTunes and Mail.app
        notification.setValue(true, forKey: "_showsButtons")
        
        notification.actionButtonTitle = "Upload"
        
        self.notificationCenter.scheduleNotification(notification)
    }
}

