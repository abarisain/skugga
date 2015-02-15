//
//  RemoteFileListViewController.swift
//  Skugga
//
//  Created by Arnaud Barisain Monrose on 12/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

import UIKit
import AssetsLibrary

class RemoteFileListViewController : UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    private var files = [RemoteFile]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        RemoteFileDatabaseHelper.refreshFromServer()
    }

    override func viewWillAppear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshData", name: RemoteFilesChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataRefreshFailed", name: RemoteFilesRefreshFailureNotification, object: nil)
        refreshData()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func uploadAction(sender: AnyObject)
    {
        //FIXME : Implement iOS 8's document provider
        var imagePicker = FixedStatusBarImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        //FIXME : Add popover support for iPads
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func refreshData()
    {
        files = RemoteFileDatabaseHelper.cachedFiles
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func dataRefreshFailed()
    {
        refreshControl?.endRefreshing()
    }
    
    private func uploadImage(image: UIImage, data: NSData, filename: String)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let uploadNavigationController = storyboard.instantiateViewControllerWithIdentifier("UploadScene") as UINavigationController
        let uploadController = uploadNavigationController.viewControllers[0] as UploadViewController
        uploadController.targetImage = image
        uploadController.targetData = data
        uploadController.targetFilename = filename
        presentViewController(uploadNavigationController, animated: true)
        { () -> Void in
            uploadController.startUpload()
        }
    }
    
    @IBAction func refreshControlPulled(sender: AnyObject)
    {
        RemoteFileDatabaseHelper.refreshFromServer()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "FileDetails"
        {
            let detailsViewController = segue.destinationViewController as FileDetailsViewController
            detailsViewController.remoteFile = files[tableView.indexPathForSelectedRow()?.row ?? 0]
        }
    }
    
    // MARK : Table delegate/datasource Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return files.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileCell") as RemoteFileTableViewCell
        
        cell.update(files[indexPath.row])
        
        return cell
    }
    
    // MARK : UIImagePickerController Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        var image = info[UIImagePickerControllerOriginalImage] as UIImage
        var url = info[UIImagePickerControllerReferenceURL] as NSURL
        
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            ALAssetsLibrary().assetForURL(url, resultBlock: { (asset: ALAsset!) -> Void in
                self.uploadImage(image, data: UIImageJPEGRepresentation(image, 1), filename: asset.defaultRepresentation().filename().stringByDeletingPathExtension)
            }, failureBlock: { (error: NSError!) -> Void in
                let alert = UIAlertController(title: "Error", message: "Couldn't upload image : \(error) \(error?.userInfo)", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
        })
    }
}

class RemoteFileTableViewCell : UITableViewCell
{
    
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    
    func update(remoteFile : RemoteFile)
    {
        filenameLabel.text = remoteFile.filename
        dateLabel.text = remoteFile.uploadDate.description
    }
}

class FixedStatusBarImagePickerController : UIImagePickerController
{
    override func prefersStatusBarHidden() -> Bool
    {
        return false
    }
    
    override func childViewControllerForStatusBarHidden() -> UIViewController?
    {
        return nil
    }
}