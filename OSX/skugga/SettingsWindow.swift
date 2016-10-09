//
//  SettingsWindow.swift
//  skugga
//
//  Created by Arnaud Barisain-Monrose on 08/02/2015.
//
//

import Foundation
import Cocoa

// TODO: We should use a view controller, but meh.
class SettingsWindow : NSWindow
{
    @IBOutlet weak var endpointTextField: NSTextField!
    
    @IBOutlet weak var secretTextField: NSSecureTextField!
    @IBOutlet weak var suffixTextField: NSTextField!
    
    required override init(contentRect: NSRect, styleMask aStyle: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool)
    {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        //refreshFields()
    }
    
    func refreshFields()
    {
        endpointTextField.stringValue = Configuration.endpoint
        secretTextField.stringValue = Configuration.secret
        suffixTextField.stringValue = Configuration.suffix
    }
    
    @IBAction func apply(_ sender: AnyObject)
    {
        Configuration.endpoint = endpointTextField.stringValue
        Configuration.secret = secretTextField.stringValue
        Configuration.suffix = suffixTextField.stringValue
    }
}
