//
//  ShareViewController.swift
//  Share
//
//  Created by arnaud on 15/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        placeholder = "Ready to upload!"
    }
    
    override func presentationAnimationDidFinish()
    {
        textView.userInteractionEnabled = false
        textView.editable = false
    }
    
    override func isContentValid() -> Bool
    {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost()
    {
        let item = self.extensionContext!.inputItems[0] as NSExtensionItem
        if let attachments = item.attachments {
            if attachments.count > 0
            {
                let attachment = attachments.first as NSItemProvider
                if attachment.hasItemConformingToTypeIdentifier(kUTTypeFileURL)
                {
                    uploadAttachmentForType(attachment, type: kUTTypeFileURL)
                    return
                }
                else if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage)

                {
                    uploadAttachmentForType(attachment, type: kUTTypeImage)
                    return
                }
            }
        } else {
            NSLog("No Attachments")
        }
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequestWithError(cancelError)
        super.didSelectPost()
    }

    override func configurationItems() -> [AnyObject]!
    {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return [AnyObject]()
    }
    
    func uploadAttachmentForType(attachment : NSItemProvider, type: String)
    {
        attachment.loadItemForTypeIdentifier(type,
            options: nil,
            completionHandler:
            { (item: NSSecureCoding!, error: NSError!) -> Void in
                if let urlItem = item as? NSURL
                {
                    let data = NSData(contentsOfURL: urlItem)
                    let alert = UIAlertController(title: "Uploading...", message: "", preferredStyle: .Alert)
                   
                    self.presentViewController(alert, animated: true, completion: nil)
                    UploadClient().uploadFile(urlItem,
                        progress: { (bytesSent: Int64, bytesToSend: Int64) -> Void in
                            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                alert.message = NSString(format: "%d %%", Int((Double(bytesSent) / Double(bytesToSend))*100))
                            })
                        }, success: { (data: [NSObject : AnyObject]) -> Void in
                            var url = data["name"] as NSString
                            url = Configuration.endpoint + url
                            
                            UIPasteboard.generalPasteboard().string = url
                            self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
                        }, failure: { (error: NSError) -> Void in
                            NSLog("Failed to upload file \(error) \(error.userInfo)")
                            alert.dismissViewControllerAnimated(true, completion: { () -> Void in
                                let alert = UIAlertController(title: "Error", message: "Couldn't upload image : \(error) \(error.userInfo)", preferredStyle: .Alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) -> () in self.extensionContext!.cancelRequestWithError(error) }))
                                self.presentViewController(alert, animated: true, completion: nil)
                            })
                    })
                }
                else
                {
                    let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
                    self.extensionContext!.cancelRequestWithError(cancelError)
                }
            }
        )
    }

}
