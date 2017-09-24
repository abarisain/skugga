//
//  RemoteFileDatabaseHelper.swift
//  Skugga
//
//  Created by arnaud on 14/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

import Foundation
import CoreData
import UpdAPI

/*!
 Notification that this helper will emit once the files have changed
 */
let RemoteFilesChangedNotification = "RemoteFilesChanged"
let RemoteFilesRefreshFailureNotification = "RemoteFilesFailedToRefresh"

struct RemoteFileDatabaseHelper
{
    
    static func refreshFromServer()
    {
        
        FileListClient(configuration: Configuration.updApiConfiguration).getFileList(saveFilesToDB, failure: { (error: NSError) -> () in
            NSLog("Error while refreshing files from server \(error), cause : \(error.userInfo)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: RemoteFilesChangedNotification), object: nil)
        })
    }
    
    static var cachedFiles: [RemoteFile]
    {
        get
        {
            let (fetchedResults, error) = readFilesFromDB()
            
            if let results = fetchedResults
            {
                return results.map({RemoteFile(fromNSManagedObject: $0)}).sorted(by: {$0.uploadDate > $1.uploadDate})
            }
            else
            {
                NSLog("Could not get cached files \(error), cause : \(error!.userInfo)")
                return [RemoteFile]()
            }
        }
    }
    
    fileprivate static func readFilesFromDB() -> ([NSManagedObject]?, NSError?)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"RemoteFile")
        
        do {
            let fetchedResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            return (fetchedResults, nil)
        } catch let error as NSError {
            return (nil, error)
        }
    }
    
    fileprivate static func truncateFilesDB()
    {
        let (fetchedResults, error) = readFilesFromDB()
        
        if let results = fetchedResults
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            for result in results
            {
                managedContext.delete(result)
            }
            
            do {
                try managedContext.save()
            } catch let saveError as NSError {
                NSLog("Could not truncate cached files \(saveError), cause : \(saveError.userInfo)")
            }
        }
        else
        {
            NSLog("Could not truncate cached files \(error), cause : \(error!.userInfo)")
        }
    }
    
    fileprivate static func saveFilesToDB(_ files: [RemoteFile])
    {
        DispatchQueue.main.async {
            truncateFilesDB()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            let entity = NSEntityDescription.entity(forEntityName: "RemoteFile", in: managedContext)
            
            for file in files
            {
                let _ = file.toNSManagedObject(managedContext, entity: entity!)
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                NSLog("Could not save remote files \(error), cause : \(error.userInfo)")
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: RemoteFilesChangedNotification), object: nil)
        }
    }
}
