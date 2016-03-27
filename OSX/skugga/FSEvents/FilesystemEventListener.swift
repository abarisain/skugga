//
//  FilesystemEventListener.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 26/03/2016.
//
//

import Foundation

public struct FilesystemEvent {
    public var id: FSEventStreamEventId
    public var path: String
    public var flags: FSEventStreamEventFlags
    public var date: NSDate
}

public class FilesystemEventListener {
    
    // MARK: Status variables
    
    public private(set) var watchedPaths: [String] = []
    
    public private(set) var listening: Bool = false
    
    public private(set) var lastEvent: FilesystemEvent?
    
    // MARK: Configuration variables
    
    public var runLoop: CFRunLoop = CFRunLoopGetMain()
    
    // Default latency is 5 seconds
    public var latency: CFTimeInterval = 5
    
    public var streamFlags: FSEventStreamCreateFlags = UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
    
    // MARK: Private variables
    
    var eventStream: FSEventStreamRef?
    
    // MARK: -
    // MARK: Lifecycle methods
    
    init() {
    }
    
    deinit {
        stopWatching()
    }
    
    // MARK: Public methods
    
    func startWatching(paths: [String], sinceWhen: FSEventStreamEventId? = nil) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard listening == false else { return }
        guard eventStream == nil else { return }
        guard paths.count > 0 else { return }
        
        let sinceWhen = sinceWhen ?? lastEvent?.id ?? FSEventStreamEventId(kFSEventStreamEventIdSinceNow)
        
        var streamContext = FSEventStreamContext(version: 0,
                                                 info: UnsafeMutablePointer<Void>(unsafeAddressOf(self)),
                                                 retain: nil,
                                                 release: nil,
                                                 copyDescription: nil)
        
        let eventCallback: FSEventStreamCallback = { (streamRef: ConstFSEventStreamRef,
                                                      clientCallBackInfo: UnsafeMutablePointer<Void>,
                                                      numEvents: Int,
                                                      eventPaths: UnsafeMutablePointer<Void>,
                                                      eventFlags: UnsafePointer<FSEventStreamEventFlags>,
                                                      eventIds: UnsafePointer<FSEventStreamEventId>) in
            
            let instance: FilesystemEventListener = unsafeBitCast(clientCallBackInfo, FilesystemEventListener.self)
            
            let paths = unsafeBitCast(eventPaths, CFArray.self)
            
            var events: [FilesystemEvent] = []
            
            for i in 0..<CFArrayGetCount(paths) {
                events.append(FilesystemEvent(id: eventIds[i],
                    path: unsafeBitCast(CFArrayGetValueAtIndex(paths, i), CFString.self) as String,
                    flags: eventFlags[i],
                    date: NSDate()))
            }
            
            instance.onEvents(events)
        }
        
        eventStream = FSEventStreamCreate(kCFAllocatorDefault,
                                          eventCallback,
                                          &streamContext,
                                          paths,
                                          sinceWhen,
                                          latency,
                                          streamFlags)
        
        FSEventStreamScheduleWithRunLoop(eventStream!, runLoop, kCFRunLoopDefaultMode)
        FSEventStreamStart(eventStream!)
        
        watchedPaths = paths
        listening = true
    }
    
    func stopWatching() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard listening == true else { return }
        guard let eventStream = eventStream else { return }
        
        FSEventStreamStop(eventStream)
        FSEventStreamUnscheduleFromRunLoop(eventStream, runLoop, kCFRunLoopDefaultMode)
        FSEventStreamInvalidate(eventStream)
        FSEventStreamRelease(eventStream)
        
        listening = false
    }
    
    // MARK: Private methods
    
    private func onEvents(events: [FilesystemEvent]) {
        guard events.count > 0 else { return }
        
        lastEvent = events.last
        
        //TODO: Call the user
    }
}