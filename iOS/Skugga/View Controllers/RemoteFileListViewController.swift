//
//  RemoteFileListViewController.swift
//  Skugga
//
//  Created by Arnaud Barisain Monrose on 12/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

import UIKit

class RemoteFileListViewController : UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
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
        //FIXME : Implement iOS 8's document provider
        var imagePicker = FixedStatusBarImagePickerController();
        imagePicker.delegate = self;
        imagePicker.sourceType = .PhotoLibrary;
        //FIXME : Add popover support for iPads
        presentViewController(imagePicker, animated: true, completion: nil);
    }

    func refreshData()
    {
        files = RemoteFileDatabaseHelper.cachedFiles;
        tableView.reloadData();
        refreshControl?.endRefreshing();
    }
    
    func dataRefreshFailed()
    {
        refreshControl?.endRefreshing();
    }
    
    private func uploadImage(image: UIImage)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let uploadNavigationController = storyboard.instantiateViewControllerWithIdentifier("UploadScene") as UINavigationController;
        let uploadController = uploadNavigationController.viewControllers[0] as UploadViewController;
        uploadController.targetImage = image;
        presentViewController(uploadNavigationController, animated: true)
        { () -> Void in
            uploadController.startUpload();
        }
    }
    
    @IBAction func refreshControlPulled(sender: AnyObject)
    {
        refreshData();
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
    
    // MARK : UIImagePickerController Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        var image = info["UIImagePickerControllerOriginalImage"] as UIImage;
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.uploadImage(image);
        });
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

class FixedStatusBarImagePickerController : UIImagePickerController
{
    override func prefersStatusBarHidden() -> Bool
    {
        return false;
    }
    
    override func childViewControllerForStatusBarHidden() -> UIViewController?
    {
        return nil;
    }
}