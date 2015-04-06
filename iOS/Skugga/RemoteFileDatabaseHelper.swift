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
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
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
                return results.map({RemoteFile(fromNSManagedObject: $0)}).sorted({$0.uploadDate > $1.uploadDate})
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
        
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        return (fetchedResults, error)
    }
    
    private static func truncateFilesDB()
    {
        let (fetchedResults, error) = readFilesFromDB()
        
        if let results = fetchedResults
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            var saveError: NSError?
            for result in results
            {
                managedContext.deleteObject(result)
            }
            
            managedContext.save(&saveError)
            if let saveError = saveError
            {
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
        
        var error: NSError?
        managedContext.save(&error)
        if let error = error
        {
            NSLog("Could not save remote files \(error), cause : \(error.userInfo)")
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(RemoteFilesChangedNotification, object: nil)
    }
}