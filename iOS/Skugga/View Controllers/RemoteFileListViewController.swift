//
//  RemoteFileListViewController.swift
//  Skugga
//
//  Created by Arnaud Barisain Monrose on 12/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

import UIKit

class RemoteFileListViewController : UITableViewController
{

    private var files = [RemoteFile]();
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        RemoteFileDatabaseHelper.refreshFromServer();
    }

    override func viewWillAppear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData", name: RemoteFilesChangedNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataRefreshFailed", name: RemoteFilesRefreshFailureNotification, object: nil);
        refreshData();
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func uploadAction(sender: AnyObject)
    {
    }

    func refreshData()
    {
        files = RemoteFileDatabaseHelper.cachedFiles;
        tableView.reloadData();
    }
    
    func dataRefreshFailed()
    {
        
    }
    
    // MARK : Table delegate/datasource Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return files.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileCell") as RemoteFileTableViewCell;
        
        cell.update(files[indexPath.row]);
        
        return cell;
    }
    
}

class RemoteFileTableViewCell : UITableViewCell
{
    
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    
    func update(remoteFile : RemoteFile)
    {
        filenameLabel.text = remoteFile.filename;
        dateLabel.text = remoteFile.uploadDate.description;
    }
}