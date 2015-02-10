//
//  RemoteFileTableCell.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 10/02/2015.
//
//

import Foundation
import Cocoa

class RemoteFileTableCell: NSTableCellView
{
    @IBOutlet weak var filename: NSTextField!
    
    @IBOutlet weak var uploadDate: NSTextField!
    
    @IBOutlet weak var icon: NSImageView!
    
    func updateWithRemoteFile(file: RemoteFile)
    {
        var fileIcon = NSWorkspace.sharedWorkspace().iconForFileType("html");
        fileIcon.size = NSSize(width: 40, height: 40);
        icon.image = fileIcon;
        filename.stringValue = file.filename;
        uploadDate.stringValue = file.uploadDate.description;
    }
}