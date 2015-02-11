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
                            NSLog("Found URL : %@", item as NSURL);
                            NSDistributedNotificationCenter.defaultCenter().postNotificationName("fr.nlss.skugga.uploadFromExtension",
                                object: nil)
                        }
                    );
                }
            }
            
        } else {
            NSLog("No Attachments")
        }
    }

    @IBAction func send(sender: AnyObject?) {
        let outputItem = NSExtensionItem()
        // Complete implementation by setting the appropriate value on the output item
    
        let outputItems = [outputItem]
        self.extensionContext!.completeRequestReturningItems(outputItems, completionHandler: nil)
}

    @IBAction func cancel(sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequestWithError(cancelError)
    }

}
