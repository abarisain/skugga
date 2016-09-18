//
//  NotificationActionManager.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 18/09/2016.
//  Copyright © 2016 NamelessDev. All rights reserved.
//

import Foundation
import UserNotifications

private struct ActionIdentifiers {
    public static let openSafari = "open_safari"
    public static let copyURL = "copy_url"
}

public struct NotificationCategories {
    public static let uploadSuccess = "upload_success"
}

class NotificationActionManager {
    
    static func notificationCategories() -> Set<UNNotificationCategory> {
        let openSafariAction = UNNotificationAction(identifier: ActionIdentifiers.openSafari, title: "Open Safari", options: [.foreground])
        let copyAction = UNNotificationAction(identifier: ActionIdentifiers.copyURL, title: "Copy URL", options: [])
        
        let uploadSuccessCategory = UNNotificationCategory(identifier: NotificationCategories.uploadSuccess, actions: [openSafariAction, copyAction], intentIdentifiers: [], options: [])
        
        return [uploadSuccessCategory]
    }
    
    static func performAction(identifier: String, userInfo: [AnyHashable : Any]) {
        if (identifier == ActionIdentifiers.openSafari) {
            if let urlString = userInfo["url"] as? String, let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if (identifier == ActionIdentifiers.copyURL) {
            if let urlString = userInfo["url"] as? String {
                UIPasteboard.general.string = urlString
            }
        }
    }
}
