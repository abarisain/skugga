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
            if let url = remoteFile.absoluteURL(baseURL: Configuration.endpoint) {
                webView.loadRequest(URLRequest(url: url))
                //TODO: Error
            }
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
                    if let url = remoteFile.absoluteURL(baseURL: Configuration.endpoint) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        //TODO: Error
                    }
            }))
            popup.addAction(UIAlertAction(title: "Copy URL",
                style: .default,
                handler: { (_) -> Void in
                    if let url = remoteFile.absoluteURL(baseURL: Configuration.endpoint) {
                        UIPasteboard.general.string = url.absoluteString
                    }
            }))
            popup.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(popup, animated: true, completion: nil)
        }
    }
}
