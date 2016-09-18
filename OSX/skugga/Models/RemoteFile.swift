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
    
    static let dateFormatter: DateFormatter =
    {
        var formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    
    var filename: String
    var uploadDate: Date
    var url: String
    var deleteKey: String
    
    init(fromNSDict dict: [AnyHashable: Any])
    {
        filename = dict["original"] as? String ?? "<unknown original name>"
        uploadDate = RemoteFile.dateFormatter.date(from: dict["creation_time"] as? String ?? "") ?? Date()
        url = dict["name"] as! String
        deleteKey = dict["delete_key"] as! String
    }
    
    init(fromNSManagedObject managedObject: NSManagedObject)
    {
        filename = managedObject.value(forKey: LocalCoreDataKeys.Filename) as! String
        uploadDate = managedObject.value(forKey: LocalCoreDataKeys.UploadDate) as! Date
        url = managedObject.value(forKey: LocalCoreDataKeys.Url) as! String
        deleteKey = managedObject.value(forKey: LocalCoreDataKeys.DeleteKey) as! String
    }
    
    func toNSManagedObject(_ context: NSManagedObjectContext, entity: NSEntityDescription) -> NSManagedObject
    {
        let managedObject = NSManagedObject(entity: entity, insertInto: context)
        
        managedObject.setValue(filename, forKey: LocalCoreDataKeys.Filename)
        managedObject.setValue(uploadDate, forKey: LocalCoreDataKeys.UploadDate)
        managedObject.setValue(url, forKey: LocalCoreDataKeys.Url)
        managedObject.setValue(deleteKey, forKey: LocalCoreDataKeys.DeleteKey)
        
        return managedObject
    }
}
