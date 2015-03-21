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
    @IBOutlet weak var menuButton: NSButton!
    
    @IBOutlet weak var filesTableView: NSTableView!
    
    var remoteFiles = [RemoteFile]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        filesTableView.target = self
        filesTableView.doubleAction = "tableDoubleClick"
        var image = menuButton.image
        if let image = image
        {
            image.setTemplate(true)
            menuButton.image = image
        }
        
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
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: Configuration.endpoint + file.url)!)
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
        pasteboard.setString(Configuration.endpoint + file.url, forType: NSStringPboardType)
    }
    
    @IBAction func tableOpenInBrowserAction(sender: AnyObject)
    {
        let file = remoteFiles[filesTableView.clickedRow]
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: Configuration.endpoint + file.url)!)
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