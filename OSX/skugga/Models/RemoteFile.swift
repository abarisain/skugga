//
//  RemoteFile.swift
//  Skugga
//
//  Created by Arnaud Barisain Monrose on 09/02/2015.
//
//

import Foundation
import CoreData

struct RemoteFile
{
    static let dateFormatter: NSDateFormatter =
    {
        var formatter = NSDateFormatter();
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX");
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        return formatter;
    }();
    
    var filename: String;
    var uploadDate: NSDate;
    var url: String;
    var deleteKey: String;
    
    init(fromNSDict dict: [NSObject: AnyObject])
    {
        filename = dict["original"] as? String ?? "<unknown original name>";
        uploadDate = RemoteFile.dateFormatter.dateFromString(dict["creation_time"] as? String ?? "") ?? NSDate();
        url = dict["name"] as String;
        deleteKey = dict["delete_key"] as String;
    }
    
    init(fromNSManagedObject managedObject: NSManagedObject)
    {
        filename = managedObject.valueForKey("filename") as? String ?? "<unknown original name>";
        uploadDate = managedObject.valueForKey("uploadDate") as NSDate;
        url = managedObject.valueForKey("url") as String;
        deleteKey = managedObject.valueForKey("deleteKey") as String;
    }
}