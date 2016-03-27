//
//  DesktopScreenshotWatcher.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 27/03/2016.
//
//

import Foundation

public class DesktopScreenshotWatcher: FilesystemEventListenerDelegate {
    
    let fsEventListener = FilesystemEventListener()
    
    let fileManager = NSFileManager.defaultManager()
    
    var screenshotFolder = ("~/Desktop" as NSString).stringByExpandingTildeInPath
    
    //TODO (arnaud): Read the capture extension https://github.com/abarisain/scrup/blob/2ffd01b52b8ada3e698d4aee7e863cb0351eb36c/src/DPAppDelegate.m#L121
    var screenshotExtension = ".png"
    
    init() {
        fsEventListener.latency = 2
        fsEventListener.delegate = self
        // TODO (arnaud): Read from screencapture https://github.com/abarisain/scrup/blob/2ffd01b52b8ada3e698d4aee7e863cb0351eb36c/src/DPAppDelegate.m#L118
        fsEventListener.watchedPaths = [screenshotFolder];
    }
    
    public func start() {
        fsEventListener.startWatching()
    }
    
    public func stop() {
        fsEventListener.stopWatching()
    }
    
    public func filesystemEventsOccurred(listener: FilesystemEventListener, events: [FilesystemEvent]) {
        // Here we will read the file attributes and ensure that:
        //  - It's a regular file
        //  - It's not older than 5 seconds (so we try to only detect recently created screenshots, and ignore copies)
        //  - NSFileExtendedAttributes has com.apple.metadata:kMDItemIsScreenCapture
        // We'll also read the event flags to filter unwanted fs events, and ignore anything that doesn't have the right file suffix
        
        let createdFlag = UInt32(kFSEventStreamEventFlagItemCreated)
        
        for event in events {
            guard event.flags & createdFlag == 0 else { continue }
            guard !event.path.hasSuffix(screenshotExtension) else { continue }
            
            //TODO: Remove this
            print("DEBUG: Candidate file \(event)")
        }
    }
}