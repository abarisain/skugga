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
    
    var remoteFiles = [RemoteFile]();
    
    override func awakeFromNib() {
        super.awakeFromNib()
        filesTableView.target = self;
        filesTableView.doubleAction = "tableDoubleClick";
    }
    
    @IBAction func menuButtonClick(sender: AnyObject)
    {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate;
        appDelegate.showMenuFromView(menuButton, window: menuButton.window!);
    }
    
    func refreshWithRemoteFiles(files: [RemoteFile])
    {
        remoteFiles = files;
        filesTableView.reloadData();
    }
    
    func tableDoubleClick()
    {
        var row = filesTableView.clickedRow;
        var file = remoteFiles[row];
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: Configuration.endpoint + file.url)!);
    }
    
    // MARK : NSTableViewDataSource methods
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        return remoteFiles.count;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        if let cell = tableView.makeViewWithIdentifier("remoteFileCell", owner: self) as? RemoteFileTableCell
        {
            cell.updateWithRemoteFile(remoteFiles[row]);
            return cell;
        }
        return nil;
    }
}