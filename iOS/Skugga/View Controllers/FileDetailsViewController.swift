//
//  FileDetailsViewController.swift
//  Skugga
//
//  Created by arnaud on 14/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

import Foundation

class FileDetailsViewController : UIViewController
{
    
    @IBOutlet weak var webView: UIWebView!
    
    var remoteFile: RemoteFile?;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        if let remoteFile = remoteFile
        {
            navigationItem.title = remoteFile.filename;
            webView.loadRequest(NSURLRequest(URL: NSURL(string: Configuration.endpoint + remoteFile.url)!));
        }
    }
    
    @IBAction func shareAction(sender: AnyObject)
    {
    }
}
