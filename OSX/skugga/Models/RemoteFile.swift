//
//  RemoteFile.swift
//  Skugga
//
//  Created by Arnaud Barisain Monrose on 09/02/2015.
//
//

import Foundation
import CoreData

private struct LocalCoreDataKeys
{
    static let Filename = "filename"
    static let UploadDate = "uploadDate"
    static let Url = "url"
    static let DeleteKey = "deleteKey"
}

struct RemoteFile
{
    
    static let dateFormatter: NSDateFormatter =
    {
        var formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    
    var filename: String
    var uploadDate: NSDate
    var url: String
    var deleteKey: String
    
    init(fromNSDict dict: [NSObject: AnyObject])
    {
        filename = dict["original"] as? String ?? "<unknown original name>"
        uploadDate = RemoteFile.dateFormatter.dateFromString(dict["creation_time"] as? String ?? "") ?? NSDate()
        url = dict["name"] as! String
        deleteKey = dict["delete_key"] as! String
    }
    
    init(fromNSManagedObject managedObject: NSManagedObject)
    {
        filename = managedObject.valueForKey(LocalCoreDataKeys.Filename) as! String
        uploadDate = managedObject.valueForKey(LocalCoreDataKeys.UploadDate) as! NSDate
        url = managedObject.valueForKey(LocalCoreDataKeys.Url) as! String
        deleteKey = managedObject.valueForKey(LocalCoreDataKeys.DeleteKey) as! String
    }
    
    func toNSManagedObject(context: NSManagedObjectContext, entity: NSEntityDescription) -> NSManagedObject
    {
        let managedObject = NSManagedObject(entity: entity, insertIntoManagedObjectContext: context)
        
        managedObject.setValue(filename, forKey: LocalCoreDataKeys.Filename)
        managedObject.setValue(uploadDate, forKey: LocalCoreDataKeys.UploadDate)
        managedObject.setValue(url, forKey: LocalCoreDataKeys.Url)
        managedObject.setValue(deleteKey, forKey: LocalCoreDataKeys.DeleteKey)
        
        return managedObject
    }
}