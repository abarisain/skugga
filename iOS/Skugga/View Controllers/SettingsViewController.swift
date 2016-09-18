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
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneAction(_ sender: AnyObject)
    {
        Configuration.endpoint = endpointTextField.text ?? ""
        Configuration.secret = secretTextField.text ?? ""
        Configuration.synchronize()
        
        dismiss(animated: true, completion: nil)
    }
}
