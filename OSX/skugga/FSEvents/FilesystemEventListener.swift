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
    public var date: Date
}

public protocol FilesystemEventListenerDelegate: class {
    func filesystemEventsOccurred(_ listener: FilesystemEventListener, events: [FilesystemEvent])
}

open class FilesystemEventListener: CustomDebugStringConvertible {
    
    // MARK: Status variables
    
    open fileprivate(set) var listening: Bool = false
    
    open fileprivate(set) var lastEvent: FilesystemEvent?
    
    // MARK: Configuration variables
    
    open var watchedPaths: [String] = []
    
    open weak var delegate: FilesystemEventListenerDelegate?
    
    open var runLoop: CFRunLoop = CFRunLoopGetMain()
    
    // Default latency is 5 seconds
    open var latency: CFTimeInterval = 5
    
    open var streamFlags: FSEventStreamCreateFlags = UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
    
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
    
    func startWatching(_ sinceWhen: FSEventStreamEventId? = nil) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard listening == false else { return }
        guard eventStream == nil else { return }
        guard watchedPaths.count > 0 else { return }
        
        let sinceWhen = sinceWhen ?? lastEvent?.id ?? FSEventStreamEventId(kFSEventStreamEventIdSinceNow)
        
        var streamContext = FSEventStreamContext(version: 0,
                                                 info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                                                 retain: nil,
                                                 release: nil,
                                                 copyDescription: nil)
        
        let eventCallback: FSEventStreamCallback = { (streamRef: ConstFSEventStreamRef,
                                                      clientCallBackInfo: UnsafeMutableRawPointer?,
                                                      numEvents: Int,
                                                      eventPaths: UnsafeMutableRawPointer,
                                                      eventFlags: UnsafePointer<FSEventStreamEventFlags>?,
                                                      eventIds: UnsafePointer<FSEventStreamEventId>?) in
            
            guard let eventFlags = eventFlags, let eventIds = eventIds else { return }
            
            let instance: FilesystemEventListener = unsafeBitCast(clientCallBackInfo, to: FilesystemEventListener.self)
            
            let paths = unsafeBitCast(eventPaths, to: CFArray.self)
            
            var events: [FilesystemEvent] = []
            
            for i in 0..<CFArrayGetCount(paths) {
                events.append(FilesystemEvent(id: eventIds[i],
                    path: unsafeBitCast(CFArrayGetValueAtIndex(paths, i), to: CFString.self) as String,
                    flags: eventFlags[i],
                    date: Date()))
            }
            
            instance.onEvents(events)
        }
        
        eventStream = FSEventStreamCreate(kCFAllocatorDefault,
                                          eventCallback,
                                          &streamContext,
                                          watchedPaths as CFArray,
                                          sinceWhen,
                                          latency,
                                          streamFlags)
        
        FSEventStreamScheduleWithRunLoop(eventStream!, runLoop, CFRunLoopMode.defaultMode as! CFString)
        FSEventStreamStart(eventStream!)
        
        listening = true
    }
    
    func stopWatching() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard listening == true else { return }
        guard let eventStream = eventStream else { return }
        
        FSEventStreamStop(eventStream)
        FSEventStreamUnscheduleFromRunLoop(eventStream, runLoop, CFRunLoopMode.defaultMode as! CFString)
        FSEventStreamInvalidate(eventStream)
        FSEventStreamRelease(eventStream)
        
        listening = false
    }
    
    // MARK: Private methods
    
    fileprivate func onEvents(_ events: [FilesystemEvent]) {
        guard events.count > 0 else { return }
        
        lastEvent = events.last
        
        delegate?.filesystemEventsOccurred(self, events: events)
    }
    
    open var debugDescription: String {
        return "FilesystemEventListener: listening=\(listening), delegate=\(delegate), watchedPaths=\(watchedPaths)"
    }
}
