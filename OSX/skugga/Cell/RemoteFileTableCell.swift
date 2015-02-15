//
//  RemoteFileTableCell.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 10/02/2015.
//
//

import Foundation
import Cocoa

private struct LocalConsts
{
    static let defaultFileType = "html"
}

class RemoteFileTableCell: NSTableCellView
{
    @IBOutlet weak var filename: NSTextField!
    
    @IBOutlet weak var uploadDate: NSTextField!
    
    @IBOutlet weak var icon: NSImageView!
    
    func updateWithRemoteFile(file: RemoteFile)
    {
        var fileType = file.filename.pathExtension
        if (fileType.isEmpty)
        {
            fileType = LocalConsts.defaultFileType
        }
        var fileIcon = NSWorkspace.sharedWorkspace().iconForFileType(fileType)
        fileIcon.size = NSSize(width: 40, height: 40)
        icon.image = fileIcon
        filename.stringValue = file.filename
        uploadDate.stringValue = file.uploadDate.description
    }
}