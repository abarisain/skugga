//
//  ShareViewController.swift
//  Share
//
//  Created by Arnaud Barisain Monrose on 11/02/2015.
//
//

import Cocoa

class ShareViewController: NSViewController {

    override var nibName: String? {
        return "ShareViewController"
    }

    override func loadView() {
        super.loadView()
    
        // Insert code here to customize the view
        let item = self.extensionContext!.inputItems[0] as NSExtensionItem
        if let attachments = item.attachments {
            if attachments.count > 0
            {
                let attachment = attachments.first as NSItemProvider;
                if attachment.hasItemConformingToTypeIdentifier(kUTTypeFileURL)
                {
                    attachment.loadItemForTypeIdentifier(kUTTypeFileURL,
                        options: nil,
                        completionHandler:
                        { (item: NSSecureCoding!, error: NSError!) -> Void in
                            if let urlItem = item as? NSURL
                            {
                                var groupUserDefaults = NSUserDefaults(suiteName: "group.fr.nlss.skugga");
                                groupUserDefaults?.setURL(item as NSURL, forKey: "shareExtensionURL");
                                NSDistributedNotificationCenter.defaultCenter().postNotificationName("fr.nlss.skugga.uploadFromExtension",
                                    object: nil);
                            }
                        }
                    );
                    self.extensionContext!.completeRequestReturningItems([item], completionHandler: nil);
                    return;
                }
            }
        } else {
            NSLog("No Attachments")
        }
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil);
        self.extensionContext!.cancelRequestWithError(cancelError);
    }

}
