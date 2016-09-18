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
        textView.isUserInteractionEnabled = false
        textView.isEditable = false
    }
    
    override func isContentValid() -> Bool
    {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost()
    {
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        if let attachments = item.attachments {
            if attachments.count > 0
            {
                let attachment = attachments.first as! NSItemProvider
                if attachment.hasItemConformingToTypeIdentifier(kUTTypeFileURL as String)
                {
                    uploadAttachmentForType(attachment, type: kUTTypeFileURL as String)
                    return
                }
                else if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String)

                {
                    uploadAttachmentForType(attachment, type: kUTTypeImage as String)
                    return
                }
            }
        } else {
            NSLog("No Attachments")
        }
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
        super.didSelectPost()
    }

    override func configurationItems() -> [Any]!
    {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return [AnyObject]()
    }
    
    func uploadAttachmentForType(_ attachment : NSItemProvider, type: String)
    {
        /*attachment.loadItem(forTypeIdentifier: type,
            options: nil,
            completionHandler:
            { (item: NSSecureCoding?, error: NSError!) -> Void in
                if let urlItem = item as? URL
                {
                    let alert = UIAlertController(title: "Uploading...", message: "", preferredStyle: .alert)
                   
                    self.present(alert, animated: true, completion: nil)
                    do {
                        var innerError: NSError?
                        
                        try UploadClient().uploadFile(urlItem,
                            progress: { (bytesSent: Int64, bytesToSend: Int64) -> Void in
                                DispatchQueue.main.sync(execute: { () -> Void in
                                    alert.message = NSString(format: "%d %%", Int((Double(bytesSent) / Double(bytesToSend))*100)) as String
                                })
                            }, success: { (data: [AnyHashable: Any]) -> Void in
                                var url = data["name"] as! NSString
                                url = Configuration.endpoint + (url as String)
                                
                                UIPasteboard.general.string = url as String
                                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                            }, failure: { (error: NSError) -> Void in
                                innerError = error
                        })
                        
                        if let innerError = innerError {
                            throw innerError
                        }
                    } catch let error as NSError {
                        NSLog("Failed to upload file \(error) \(error.userInfo)")
                        alert.dismiss(animated: true, completion: { () -> Void in
                            let alert = UIAlertController(title: "Error", message: "Couldn't upload image : \(error) \(error.userInfo)", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) -> () in self.extensionContext!.cancelRequest(withError: error) }))
                            self.present(alert, animated: true, completion: nil)
                        })
                    } catch {}
                }
                else
                {
                    let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
                    self.extensionContext!.cancelRequest(withError: cancelError)
                }
            }
        )*/
    }

}
