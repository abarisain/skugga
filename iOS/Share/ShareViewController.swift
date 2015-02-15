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
        super.viewDidLoad();
        placeholder = "Ready to upload!"
        textView.userInteractionEnabled = false;
        textView.editable = false;
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
                let attachment = attachments.first as NSItemProvider;
                if attachment.hasItemConformingToTypeIdentifier(kUTTypeFileURL)
                {
                    uploadAttachmentForType(attachment, type: kUTTypeFileURL);
                    return;
                }
                else if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage)

                {
                    uploadAttachmentForType(attachment, type: kUTTypeImage);
                    return;
                }
            }
        } else {
            NSLog("No Attachments")
        }
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil);
        self.extensionContext!.cancelRequestWithError(cancelError);
        super.didSelectPost();
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
                NSLog("%@", (item as AnyObject).description);
                if let urlItem = item as? NSURL
                {
                    UploadClient().
                }
                else
                {
                    let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil);
                    self.extensionContext!.cancelRequestWithError(cancelError);
                }
            }
        );
    }

}
