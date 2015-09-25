//
//  RemoteFileDatabaseHelper.swift
//  Skugga
//
//  Created by arnaud on 14/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

import Foundation
import CoreData

/*!
 Notification that this helper will emit once the files have changed
 */
let RemoteFilesChangedNotification = "RemoteFilesChanged"
let RemoteFilesRefreshFailureNotification = "RemoteFilesFailedToRefresh"

struct RemoteFileDatabaseHelper
{
    
    static func refreshFromServer()
    {
        
        FileListClient().getFileList(saveFilesToDB, failure: { (error: NSError) -> () in
            NSLog("Error while refreshing files from server \(error), cause : \(error.userInfo)")
            NSNotificationCenter.defaultCenter().postNotificationName(RemoteFilesChangedNotification, object: nil)
        })
    }
    
    static var cachedFiles: [RemoteFile]
    {
        get
        {
            let (fetchedResults, error) = readFilesFromDB()
            
            if let results = fetchedResults
            {
                return results.map({RemoteFile(fromNSManagedObject: $0)}).sort({$0.uploadDate > $1.uploadDate})
            }
            else
            {
                NSLog("Could not get cached files \(error), cause : \(error!.userInfo)")
                return [RemoteFile]()
            }
        }
    }
    
    private static func readFilesFromDB() -> ([NSManagedObject]?, NSError?)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"RemoteFile")
        
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            return (fetchedResults, nil)
        } catch let error as NSError {
            return (nil, error)
        }
    }
    
    private static func truncateFilesDB()
    {
        let (fetchedResults, error) = readFilesFromDB()
        
        if let results = fetchedResults
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            for result in results
            {
                managedContext.deleteObject(result)
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
    
    private static func saveFilesToDB(files: [RemoteFile])
    {
        truncateFilesDB()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("RemoteFile", inManagedObjectContext: managedContext)
        
        for file in files
        {
            file.toNSManagedObject(managedContext, entity: entity!)
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            NSLog("Could not save remote files \(error), cause : \(error.userInfo)")
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(RemoteFilesChangedNotification, object: nil)
    }
}