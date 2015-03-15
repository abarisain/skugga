//
//  AdvancedUploadViewController.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 15/03/2015.
//
//

import Foundation
import Cocoa

class AdvancedUploadViewController : NSViewController
{
    internal var fileToUpload: NSURL!
    {
        didSet
        {
            filenameTextField.stringValue = fileToUpload.lastPathComponent ?? ""
        }
    }
    
    @IBOutlet weak var filenameTextField: NSTextField!
    @IBOutlet weak var tagsTokenField: NSTokenField!
    @IBOutlet weak var ttlTextField: NSTextField!
    
    @IBOutlet weak var retinaCheckbox: NSButton!
    
    // MARK : IBActions
    
    @IBAction func uploadClicked(sender: AnyObject)
    {
    }
    
    @IBAction func cancelClicked(sender: AnyObject)
    {
        // TODO : Implement this using a delegate
    }
}