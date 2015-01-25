//
//  PopoverViewController.swift
//  skugga
//
//  Created by arnaud on 25/01/2015.
//
//

import Foundation
import Cocoa

class PopoverViewController: NSViewController
{
    @IBOutlet weak var menuButton: NSButton!
    
    @IBAction func menuButtonClick(sender: AnyObject)
    {
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate;
        appDelegate.showMenuFromView(menuButton, window: menuButton.window!);
    }
}