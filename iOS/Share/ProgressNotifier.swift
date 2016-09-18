//
//  ProgressNotifier.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 18/09/2016.
//  Copyright © 2016 NamelessDev. All rights reserved.
//

import Foundation
import UserNotifications

protocol ProgressNotifier {
    func uploadStarted(itemURL: URL?)
    
    func uploadProgress(percentage: Int)
    
    func uploadSuccess(url: String)
    
    func uploadFailed(error: NSError)
}

class NotificationProgressNotifier: ProgressNotifier {
    
    static let notificationUploadIdentifier = "extension_upload"
    
    var alreadyNotifiedProgress = false
    
    var alert: UIAlertController?
    
    var cachedItemURL: URL?
    
    weak var viewController: UIViewController?
    
    required init(vc: UIViewController) {
        viewController = vc
    }
    
    func uploadStarted(itemURL: URL?) {
        cachedItemURL = itemURL
        
        let content = UNMutableNotificationContent()
        content.body = "Uploading..."
        content.sound = nil
        
        let request = UNNotificationRequest.init(identifier: NotificationProgressNotifier.notificationUploadIdentifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        
        if let viewController = viewController {
            alert = UIAlertController(title: "Uploading...", message: "", preferredStyle: .alert)
            viewController.present(alert!, animated: true, completion: nil)
        }
    }
    
    func uploadProgress(percentage: Int) {
        if (percentage >= 60 && !alreadyNotifiedProgress) {
            alreadyNotifiedProgress = true
            let content = UNMutableNotificationContent()
            content.body = "Uploading... \(percentage) %"
            content.sound = nil
            
            let request = UNNotificationRequest.init(identifier: NotificationProgressNotifier.notificationUploadIdentifier, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func uploadSuccess(url: String) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [NotificationProgressNotifier.notificationUploadIdentifier])
        
        let content = UNMutableNotificationContent()
        content.title = "Image uploaded"
        content.body = "\(url)"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "upload_success"
        content.userInfo["url"] = url
        appendAttachment(content: content)
        
        let request = UNNotificationRequest.init(identifier: UUID.init().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        
        alert?.dismiss(animated: true, completion: nil)
    }
    
    func uploadFailed(error: NSError) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [NotificationProgressNotifier.notificationUploadIdentifier])
        
        let content = UNMutableNotificationContent()
        content.title = "Couldn't upload image"
        content.body = "\(error)"
        content.sound = UNNotificationSound.default()
        appendAttachment(content: content)
        
        let request = UNNotificationRequest.init(identifier: UUID.init().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        
        alert?.dismiss(animated: true, completion: nil)
    }
    
    func appendAttachment(content: UNMutableNotificationContent) {
        if let cachedItemURL = cachedItemURL {
            do {
                let attachment = try UNNotificationAttachment(identifier: "image", url: cachedItemURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print("Error while adding notification attachment \(error)")
            }
        }
    }
}

class AlertProgressNotifier: ProgressNotifier {
    
    var alert: UIAlertController?
    
    weak var viewController: UIViewController?
    
    required init(vc: UIViewController) {
        viewController = vc
    }
    
    func uploadStarted(itemURL: URL?) {
        if let viewController = viewController {
            alert = UIAlertController(title: "Uploading...", message: "", preferredStyle: .alert)
            viewController.present(alert!, animated: true, completion: nil)
        }
    }
    
    func uploadProgress(percentage: Int) {
        alert?.message = NSString(format: "%d %%", percentage) as String
    }
    
    func uploadSuccess(url: String) {
        alert?.dismiss(animated: true, completion: nil)
    }
    
    func uploadFailed(error: NSError) {
        let presentError = { () -> Void in
            let alert = UIAlertController(title: "Error", message: "Couldn't upload image : \(error) \(error.userInfo)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) -> () in
                self.viewController?.extensionContext!.cancelRequest(withError: error)
            }))
            self.viewController?.present(alert, animated: true, completion: nil)
        }
        
        if let previousAlert = alert {
            previousAlert.dismiss(animated: true, completion: presentError)
        } else {
            presentError()
        }
    }
}
