//
//  PopoverViewController.swift
//  skugga
//
//  Created by arnaud on 25/01/2015.
//
//

import Foundation
import Cocoa

class PopoverViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate
{
    @IBOutlet weak var appTitleLabel: NSTextField!
    
    @IBOutlet weak var menuButton: NSButton!
    
    @IBOutlet weak var filesTableView: NSTableView!
    
    var remoteFiles = [RemoteFile]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        filesTableView.target = self
        filesTableView.doubleAction = "tableDoubleClick"
    }
    
    @IBAction func menuButtonClick(sender: AnyObject)
    {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.showMenuFromView(menuButton, window: menuButton.window!)
    }
    
    func reloadData()
    {
        filesTableView.reloadData()
    }
    
    func refreshWithRemoteFiles(files: [RemoteFile])
    {
        remoteFiles = files
        filesTableView.reloadData()
    }
    
    func tableDoubleClick()
    {
        var row = filesTableView.clickedRow
        var file = remoteFiles[row]
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: Configuration.endpoint + file.url + Configuration.suffix)!)
    }
    
    // MARK : NSTableViewDataSource methods
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        return remoteFiles.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        if let cell = tableView.makeViewWithIdentifier("remoteFileCell", owner: self) as? RemoteFileTableCell
        {
            cell.updateWithRemoteFile(remoteFiles[row])
            return cell
        }
        return nil
    }
    
    // MARK : Table menu methods
    
    @IBAction func tableCopyLinkAction(sender: AnyObject)
    {
        let file = remoteFiles[filesTableView.clickedRow]
        let pasteboard = NSPasteboard.generalPasteboard()
        pasteboard.clearContents()
        pasteboard.setString(Configuration.endpoint + file.url + Configuration.suffix, forType: NSStringPboardType)
    }
    
    @IBAction func tableOpenInBrowserAction(sender: AnyObject)
    {
        let file = remoteFiles[filesTableView.clickedRow]
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: Configuration.endpoint + file.url + Configuration.suffix)!)
    }
    
    @IBAction func tableDeleteAction(sender: AnyObject)
    {
        FileListClient().deleteFile(remoteFiles[filesTableView.clickedRow],
            success: { () -> () in
                (NSApplication.sharedApplication().delegate as! AppDelegate).refreshFileList()
            }, failure: { (error: NSError) -> () in
                NSLog("Failed to delete file")
        });
    }
    
}

class PopoverTitleView : NSView, NSDraggingDestination {
    var appDelegate: AppDelegate
    {
        get
        {
            return NSApplication.sharedApplication().delegate as! AppDelegate
        }
    }
    
    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        setupDragAndDrop()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        setupDragAndDrop()
    }
    
    func setupDragAndDrop()
    {
        registerForDraggedTypes([NSURLPboardType])
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation
    {
        return appDelegate.draggingEntered(sender)
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool
    {
        return true
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        return appDelegate.performDragOperation(sender)
    }
}