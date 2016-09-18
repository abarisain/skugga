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
import UserNotifications

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
        UNUserNotificationCenter.current().getNotificationSettings { (settings: UNNotificationSettings) in
            var backgroundUpload = false
            
            var progressNotifier: ProgressNotifier! = nil
            
            if (settings.alertSetting == .enabled)
            {
                backgroundUpload = true
                progressNotifier = NotificationProgressNotifier(vc: self)
            }
            else
            {
                progressNotifier = AlertProgressNotifier(vc: self)
            }
            
            attachment.loadItem(forTypeIdentifier: type,
                                options: nil,
                                completionHandler:
                { (item: NSSecureCoding?, error: Error?) -> Void in
                    if let urlItem = item as? URL
                    {
                        var tmpFileURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                        tmpFileURL.appendPathComponent(UUID.init().uuidString + "." + urlItem.pathExtension)
                        
                        var attachmentURL: URL? = nil
                        
                        do {
                            try FileManager.default.copyItem(at: urlItem, to: tmpFileURL)
                            attachmentURL = tmpFileURL;
                        } catch {
                            print("Error while copying the image to a temporary directory: \(error)")
                        }
                        
                        progressNotifier.uploadStarted(itemURL: attachmentURL)
                        
                        do {
                            var innerError: NSError?
                            
                            let _ = try UploadClient().uploadFile(urlItem,
                                                                  progress: { (bytesSent: Int64, bytesToSend: Int64) -> Void in
                                                                    DispatchQueue.main.sync(execute: { () -> Void in
                                                                        progressNotifier.uploadProgress(percentage: Int((Double(bytesSent) / Double(bytesToSend))*100))
                                                                    })
                                }, success: { (data: [AnyHashable: Any]) -> Void in
                                    var url = data["name"] as! String
                                    url = Configuration.endpoint + url
                                    
                                    UIPasteboard.general.string = url
                                    
                                    progressNotifier.uploadSuccess(url: url)
                                    
                                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                                    
                                }, failure: { (error: NSError) -> Void in
                                    innerError = error
                            })
                            
                            if let innerError = innerError {
                                throw innerError
                            }
                        } catch let error as NSError {
                            NSLog("Failed to upload file \(error) \(error.userInfo)")
                            progressNotifier.uploadFailed(error: error)
                            
                            if (backgroundUpload) {
                                self.extensionContext!.cancelRequest(withError: error)
                            }
                        } catch {}
                    }
                    else
                    {
                        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
                        self.extensionContext!.cancelRequest(withError: cancelError)
                    }
                }
            )
        }
    }

}
