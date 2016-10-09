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
    internal var fileToUpload: URL!
    {
        didSet
        {
            filenameTextField.stringValue = fileToUpload.lastPathComponent 
        }
    }
    
    internal weak var delegate: AdvancedUploadViewDelegate?
    
    @IBOutlet weak var filenameTextField: NSTextField!
    @IBOutlet weak var tagsTokenField: NSTokenField!
    @IBOutlet weak var ttlTextField: NSTextField!
    
    @IBOutlet weak var retinaCheckbox: NSButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        let tokenizingSet = NSMutableCharacterSet.whitespaceAndNewline()
        tokenizingSet.formUnion(with: CharacterSet.punctuationCharacters)
        tagsTokenField.tokenizingCharacterSet = tokenizingSet as CharacterSet!
    }
    
    // MARK : IBActions
    
    @IBAction func uploadClicked(_ sender: AnyObject)
    {
        delegate?.dismissAdvancedUploadPopover()
    }
    
    @IBAction func cancelClicked(_ sender: AnyObject)
    {
        delegate?.dismissAdvancedUploadPopover()
    }
}

protocol AdvancedUploadViewDelegate: class
{
    func uploadURL(_ url: URL, filename: String, tags: String, ttl: String?, retina: Bool)
    
    func dismissAdvancedUploadPopover()
}
