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
    
    var remoteFile: RemoteFile?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        webView.scalesPageToFit = true
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
            navigationItem.title = remoteFile.filename
            webView.loadRequest(NSURLRequest(URL: NSURL(string: Configuration.endpoint + remoteFile.url)!))
        }
    }
    
    @IBAction func shareAction(sender: AnyObject)
    {
        if let remoteFile = remoteFile
        {
            let popup = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            popup.addAction(UIAlertAction(title: "Open in Safari",
                style: .Default,
                handler: { (_) -> Void in
                    // Eat the return value, otherwise it won't compile. Yay swift :)
                    _ = UIApplication.sharedApplication().openURL(NSURL(string: Configuration.endpoint + remoteFile.url)!)
            }))
            popup.addAction(UIAlertAction(title: "Copy URL",
                style: .Default,
                handler: { (_) -> Void in
                    UIPasteboard.generalPasteboard().string = Configuration.endpoint + remoteFile.url
            }))
            popup.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(popup, animated: true, completion: nil)
        }
    }
}
