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
    
    internal weak var delegate: AdvancedUploadViewDelegate?
    
    @IBOutlet weak var filenameTextField: NSTextField!
    @IBOutlet weak var tagsTokenField: NSTokenField!
    @IBOutlet weak var ttlTextField: NSTextField!
    
    @IBOutlet weak var retinaCheckbox: NSButton!
    
    // MARK : IBActions
    
    @IBAction func uploadClicked(sender: AnyObject)
    {
        delegate?.dismissAdvancedUploadPopover()
    }
    
    @IBAction func cancelClicked(sender: AnyObject)
    {
        delegate?.dismissAdvancedUploadPopover()
    }
}

protocol AdvancedUploadViewDelegate: class
{
    func uploadURL(url: NSURL, filename: String, tags: String, ttl: String?, retina: Bool)
    
    func dismissAdvancedUploadPopover()
}