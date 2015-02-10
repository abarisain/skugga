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
    
    func updateWithRemoteFile(file: RemoteFile)
    {
        filename.stringValue = file.filename;
        uploadDate.stringValue = file.uploadDate.description;
    }
}