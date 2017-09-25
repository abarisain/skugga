//
//  DesktopScreenshotWatcher.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 27/03/2016.
//
//

import Foundation

public protocol DesktopScreenshotWatcherDelegate: class {
    func desktopScreenshotCreated(_ path: String)
}

open class DesktopScreenshotWatcher: FilesystemEventListenerDelegate {
    
    let maxFileAge = 5.0
    
    let fsEventListener = FilesystemEventListener()
    
    let fileManager = FileManager.default
    
    var screenshotFolder = ("~/Desktop" as NSString).standardizingPath
    
    //TODO (arnaud): Read the capture extension https://github.com/abarisain/scrup/blob/2ffd01b52b8ada3e698d4aee7e863cb0351eb36c/src/DPAppDelegate.m#L121
    var screenshotExtension = ".png"
    
    open weak var delegate: DesktopScreenshotWatcherDelegate?
    
    init() {
        fsEventListener.latency = 2
        fsEventListener.delegate = self
        // TODO (arnaud): Read from screencapture https://github.com/abarisain/scrup/blob/2ffd01b52b8ada3e698d4aee7e863cb0351eb36c/src/DPAppDelegate.m#L118
        fsEventListener.watchedPaths = [screenshotFolder];
    }
    
    open func start() {
        fsEventListener.startWatching()
    }
    
    open func stop() {
        fsEventListener.stopWatching()
    }
    
    open func filesystemEventsOccurred(_ listener: FilesystemEventListener, events: [FilesystemEvent]) {
        // Here we will read the file attributes and ensure that:
        //  - It's a regular file
        //  - It's not older than 5 seconds (so we try to only detect recently created screenshots, and ignore copies)
        //  - NSFileExtendedAttributes has com.apple.metadata:kMDItemIsScreenCapture
        // We'll also read the event flags to filter unwanted fs events, and ignore anything that doesn't have the right file suffix
        
        let renamedFlag = UInt32(kFSEventStreamEventFlagItemRenamed)
        let xattrsModifiedFlag = UInt32(kFSEventStreamEventFlagItemXattrMod)
        
        for event in events {
            guard event.flags & renamedFlag != 0 else { continue }
            // We get two events per screenshot. Ignore one
            guard event.flags & xattrsModifiedFlag != 0 else { continue }
            guard event.path.hasSuffix(screenshotExtension) else { continue }
            // Ignore subfolders
            guard (event.path as NSString).deletingLastPathComponent == screenshotFolder else { continue }
            
            do {
                let attrs = try fileManager.attributesOfItem(atPath: event.path)
                
                guard attrs[FileAttributeKey.type] as? FileAttributeType == FileAttributeType.typeRegular else { continue }
                
                // Exclude files that are too old
                guard let modificationDate = attrs[FileAttributeKey.modificationDate] as? Date else { continue }
                guard modificationDate.compare(Date.init(timeIntervalSinceNow: -maxFileAge)) != .orderedAscending else { continue }
                
                guard let xattrs = attrs[FileAttributeKey(rawValue: "NSFileExtendedAttributes")] as? [String : AnyObject] else { continue }
                guard xattrs["com.apple.metadata:kMDItemIsScreenCapture"] != nil else { continue }
                
                delegate?.desktopScreenshotCreated(event.path)
            } catch let error as NSError {
                print("Error while reading file attributes: \(error.localizedDescription)")
            }
        }
    }
}
