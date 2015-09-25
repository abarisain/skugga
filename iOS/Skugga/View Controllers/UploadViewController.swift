//
//  UploadViewController.swift
//  Skugga
//
//  Created by arnaud on 14/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

import Foundation

class UploadViewController : UIViewController
{
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var filenameLabel: UILabel!
    
    var targetImage: UIImage?
    var targetData: NSData?
    var targetFilename: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        backgroundImageView.image = targetImage
        filenameLabel.text = targetFilename
        progressView.progress = 0
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startUpload()
    {
        do {
            try UploadClient().uploadFile(targetData!,
                filename: targetFilename ?? "iOS Image " + NSDate().description,
                mimetype: "image/jpeg",
                progress: { (bytesSent:Int64, bytesToSend:Int64) -> Void in
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        
                        self.progressView.progress = Float(Double(bytesSent) / Double(bytesToSend))
                    })
                }, success: { (data: [NSObject : AnyObject]) -> Void in
                    
                    var url = data["name"] as! NSString
                    url = Configuration.endpoint + (url as String)
                    
                    let alert = UIAlertController(title: "Image uploaded!", message: "\(url) has been copied to your clipboard", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,
                        handler: { (action: UIAlertAction!) -> () in
                            UIPasteboard.generalPasteboard().string = url as String
                            self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    // Start refreshing the file list, and hope it will be fresh for the RemoteFile list view
                    RemoteFileDatabaseHelper.refreshFromServer()
                    
                }, failure: { (error: NSError) -> Void in
                    self.onFailure(error)
            })
        } catch let error as NSError {
            self.onFailure(error)
        }
    }
    
    func onFailure(error: NSError)
    {
        
        let alert = UIAlertController(title: "Error", message: "Couldn't upload image : \(error) \(error.userInfo)", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> () in self.dismissViewControllerAnimated(true, completion: nil) }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}