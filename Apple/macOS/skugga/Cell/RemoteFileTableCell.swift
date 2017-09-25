//
//  RemoteFileTableCell.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 10/02/2015.
//
//

import Foundation
import Cocoa
import OTWebImage
import UpdAPI
import DateToolsSwift

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
    
    func updateWithRemoteFile(_ file: RemoteFile)
    {
        var fileType = (file.filename as NSString).pathExtension
        if (fileType.isEmpty)
        {
            fileType = LocalConsts.defaultFileType
        }
        fileIcon = NSWorkspace.shared().icon(forFileType: fileType)
        fileIcon?.size = NSSize(width: 40, height: 40)
        filename.stringValue = file.filename
        uploadDate.stringValue = file.uploadDate.timeAgoSinceNow
        icon.image = fileIcon
        
        icon.imageURL = URL(string: NSString(format: "%@%@?w=0&h=%.0f", Configuration.endpoint, file.url, icon.bounds.height == 0 ? 128 : icon.bounds.height) as String)!
    }
    
    func imageView(_ imageView: NSImageView!, downloadImageSuccessed image: NSImage!, data: Data!)
    {
    }
    
    func imageViewDownloadImageFailed(_ imageView: NSImageView!)
    {
        icon.image = fileIcon
    }
}
