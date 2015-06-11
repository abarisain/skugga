//
//  SettingsViewController.swift
//  Skugga
//
//  Created by arnaud on 14/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

import Foundation

class SettingsViewController : UITableViewController
{
    
    @IBOutlet weak var endpointTextField: UITextField!
    
    @IBOutlet weak var secretTextField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        endpointTextField.text = Configuration.endpoint
        secretTextField.text = Configuration.secret
        
        if "" == Configuration.endpoint {
            let alert = UIAlertController(title: "First start", message: "Hello! It looks like you haven't configured Skugga yet. In order to begin, please input your server URL and Secret if applicable.\nThis is required for the application to work.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneAction(sender: AnyObject)
    {
        if !endpointTextField.text.hasPrefix("http")
        {
            let alert = UIAlertController(title: "Error", message: "Please enter a valid server URL.\nIt must begin by http or https.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        if !endpointTextField.text.hasSuffix("/")
        {
            endpointTextField.text = endpointTextField.text + "/"
        }
        
        Configuration.endpoint = endpointTextField.text
        Configuration.secret = secretTextField.text
        Configuration.synchronize()
        
        RemoteFileDatabaseHelper.refreshFromServer()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
