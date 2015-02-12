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
    
    required override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool)
    {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag);
        //refreshFields();
    }

    // Required, but we don't care
    required init?(coder: NSCoder)
    {
        super.init(coder: coder);
    }
    
    func refreshFields()
    {
        endpointTextField.stringValue = Configuration.endpoint;
        secretTextField.stringValue = Configuration.secret;
    }
    
    @IBAction func apply(sender: AnyObject)
    {
        Configuration.endpoint = endpointTextField.stringValue;
        Configuration.secret = secretTextField.stringValue;
    }
}