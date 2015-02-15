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

class RemoteFileTableCell: NSTableCellView, NSImageViewWebCacheDelegate
{
    @IBOutlet weak var filename: NSTextField!
    
    @IBOutlet weak var uploadDate: NSTextField!
    
    @IBOutlet weak var icon: NSImageView!
    
    var fileIcon: NSImage?
    
    func updateWithRemoteFile(file: RemoteFile)
    {
        var fileType = file.filename.pathExtension
        if (fileType.isEmpty)
        {
            fileType = LocalConsts.defaultFileType
        }
        fileIcon = NSWorkspace.sharedWorkspace().iconForFileType(fileType)
        fileIcon?.size = NSSize(width: 40, height: 40)
        filename.stringValue = file.filename
        uploadDate.stringValue = file.uploadDate.description
        icon.image = fileIcon
        
        icon.imageURL = NSURL(string: NSString(format: "%@%@?w=%.0f&h=%.0f", Configuration.endpoint, file.url, icon.bounds.width, icon.bounds.height))!
    }
    
    func imageView(imageView: NSImageView!, downloadImageSuccessed image: NSImage!, data: NSData!)
    {
    }
    
    func imageViewDownloadImageFailed(imageView: NSImageView!)
    {
        icon.image = fileIcon
    }
}