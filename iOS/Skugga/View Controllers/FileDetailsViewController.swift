//
//  FileDetailsViewController.swift
//  Skugga
//
//  Created by arnaud on 14/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

import Foundation
import UpdAPI

@objc
@objcMembers
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
    
    override func viewWillAppear(_ animated: Bool)
    {
        if let remoteFile = remoteFile
        {
            navigationItem.title = remoteFile.filename
            webView.loadRequest(URLRequest(url: URL(string: Configuration.endpoint + remoteFile.url)!))
        }
    }
    
    @IBAction func shareAction(_ sender: AnyObject)
    {
        if let remoteFile = remoteFile
        {
            let popup = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            popup.addAction(UIAlertAction(title: "Open in Safari",
                style: .default,
                handler: { (_) -> Void in
                    // Eat the return value, otherwise it won't compile. Yay swift :)
                    _ = UIApplication.shared.openURL(URL(string: Configuration.endpoint + remoteFile.url)!)
            }))
            popup.addAction(UIAlertAction(title: "Copy URL",
                style: .default,
                handler: { (_) -> Void in
                    UIPasteboard.general.string = Configuration.endpoint + remoteFile.url
            }))
            popup.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(popup, animated: true, completion: nil)
        }
    }
}
