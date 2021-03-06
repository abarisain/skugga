//
//  UploadViewController.swift
//  Skugga
//
//  Created by arnaud on 14/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

import Foundation
import UserNotifications
import UpdAPI

@objc
@objcMembers
class UploadViewController : UIViewController
{
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var filenameLabel: UILabel!
    
    var targetImage: UIImage?
    var targetData: Data?
    var targetFilename: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            let _ = try UploadClient(configuration: Configuration.updApiConfiguration).upload(data: targetData!,
                filename: targetFilename ?? "iOS Image " + Date().description,
                mimetype: "image/jpeg",
                progress: { (progress: Double) in
                    self.progressView.progress = Float(progress)
                }, success: { (file) in
                    
                    var url = file.url
                    url = Configuration.endpoint + url
                    
                    let alert = UIAlertController(title: "Image uploaded!", message: "\(url) has been copied to your clipboard", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
                        handler: { (action: UIAlertAction!) -> () in
                            UIPasteboard.general.string = url as String
                            self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Image uploaded"
                    content.body = "\(url)"
                    content.sound = UNNotificationSound.default()
                    content.categoryIdentifier = "upload_success"
                    content.userInfo["url"] = url
                    
                    if let targetData = self.targetData {
                        do {
                            
                            var tmpFileURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                            tmpFileURL.appendPathComponent(UUID.init().uuidString + ".jpg")
                            
                            try targetData.write(to: tmpFileURL)
                            
                            let attachment = try UNNotificationAttachment(identifier: "image", url: tmpFileURL, options: nil)
                            content.attachments = [attachment]
                            
                        } catch {
                            print("Unknown error while trying to add image attachment: \(error)")
                        }
                    }
                    
                    let request = UNNotificationRequest.init(identifier: UUID.init().uuidString, content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request)
                    
                    // Start refreshing the file list, and hope it will be fresh for the RemoteFile list view
                    RemoteFileDatabaseHelper.refreshFromServer()
                    
                }, failure: { (error: Error) -> Void in
                    self.onFailure(error)
            })
        } catch {
            self.onFailure(error)
        }
    }
    
    func onFailure(_ error: Error)
    {
        let errorInfo = (error as? LocalizedError)?.errorDescription ?? "Unknown error"
        let alert = UIAlertController(title: "Error", message: "Couldn't upload image : \(errorInfo)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) -> () in self.dismiss(animated: true, completion: nil) }))
        self.present(alert, animated: true, completion: nil)
    }
}
