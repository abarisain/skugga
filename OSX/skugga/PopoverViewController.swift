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
        filesTableView.doubleAction = #selector(PopoverViewController.tableDoubleClick)
    }
    
    @IBAction func menuButtonClick(_ sender: AnyObject)
    {
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        appDelegate.showMenuFromView(menuButton, window: menuButton.window!)
    }
    
    func reloadData()
    {
        filesTableView.reloadData()
    }
    
    func refreshWithRemoteFiles(_ files: [RemoteFile])
    {
        remoteFiles = files
        filesTableView.reloadData()
    }
    
    func tableDoubleClick()
    {
        let row = filesTableView.clickedRow
        let file = remoteFiles[row]
        NSWorkspace.shared().open(URL(string: Configuration.endpoint + file.url + Configuration.suffix)!)
    }
    
    // MARK : NSTableViewDataSource methods
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return remoteFiles.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        if let cell = tableView.make(withIdentifier: "remoteFileCell", owner: self) as? RemoteFileTableCell
        {
            cell.updateWithRemoteFile(remoteFiles[row])
            return cell
        }
        return nil
    }
    
    // MARK : Table menu methods
    
    @IBAction func tableCopyLinkAction(_ sender: AnyObject)
    {
        let file = remoteFiles[filesTableView.clickedRow]
        let pasteboard = NSPasteboard.general()
        pasteboard.clearContents()
        pasteboard.setString(Configuration.endpoint + file.url + Configuration.suffix, forType: NSStringPboardType)
    }
    
    @IBAction func tableOpenInBrowserAction(_ sender: AnyObject)
    {
        let file = remoteFiles[filesTableView.clickedRow]
        NSWorkspace.shared().open(URL(string: Configuration.endpoint + file.url + Configuration.suffix)!)
    }
    
    @IBAction func tableDeleteAction(_ sender: AnyObject)
    {
        FileListClient().deleteFile(remoteFiles[filesTableView.clickedRow],
            success: { () -> () in
                (NSApplication.shared().delegate as! AppDelegate).refreshFileList()
            }, failure: { (error: NSError) -> () in
                NSLog("Failed to delete file")
        });
    }
    
}

class PopoverTitleView : NSView {
    var appDelegate: AppDelegate
    {
        get
        {
            return NSApplication.shared().delegate as! AppDelegate
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
        register(forDraggedTypes: [NSURLPboardType])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation
    {
        return appDelegate.draggingEntered(sender)
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool
    {
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return appDelegate.performDragOperation(sender)
    }
}
