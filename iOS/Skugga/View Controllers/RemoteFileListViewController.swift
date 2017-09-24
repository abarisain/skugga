//
//  RemoteFileListViewController.swift
//  Skugga
//
//  Created by Arnaud Barisain Monrose on 12/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

import UIKit
import AssetsLibrary
import DateToolsSwift
import UpdAPI

@objc
@objcMembers
class RemoteFileListViewController : UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerPreviewingDelegate
{

    fileprivate var files = [RemoteFile]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if "" == Configuration.endpoint {
            performSegue(withIdentifier: "settings", sender: self)
        } else {
            RemoteFileDatabaseHelper.refreshFromServer()
        }
        
        if #available(iOS 9, *) {
            if traitCollection.forceTouchCapability == .available {
                /*
                Register for `UIViewControllerPreviewingDelegate` to enable
                "Peek" and "Pop".
                
                The view controller will be automatically unregistered when it is
                deallocated.
                */
                registerForPreviewing(with: self, sourceView: view)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(RemoteFileListViewController.refreshData), name: NSNotification.Name(rawValue: RemoteFilesChangedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RemoteFileListViewController.dataRefreshFailed), name: NSNotification.Name(rawValue: RemoteFilesRefreshFailureNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RemoteFileListViewController.uploadShortcut), name: NSNotification.Name(rawValue: UploadActionNotification), object: nil)
        refreshData()
        
        if let app = UIApplication.shared.delegate as? AppDelegate , app.doUploadAction {
            app.doUploadAction = false
            uploadShortcut()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func uploadShortcut()
    {
        uploadAction(self)
    }
    
    @IBAction func uploadAction(_ sender: AnyObject)
    {
        //FIXME : Implement iOS 8's document provider
        let imagePicker = FixedStatusBarImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        //FIXME : Add popover support for iPads
        present(imagePicker, animated: true, completion: nil)
    }

    @objc func refreshData()
    {
        DispatchQueue.main.async {
            self.files = RemoteFileDatabaseHelper.cachedFiles
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    @objc func dataRefreshFailed()
    {
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func uploadImage(_ image: UIImage, data: Data, filename: String)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let uploadNavigationController = storyboard.instantiateViewController(withIdentifier: "UploadScene") as! UINavigationController
        let uploadController = uploadNavigationController.viewControllers[0] as! UploadViewController
        uploadController.targetImage = image
        uploadController.targetData = data
        uploadController.targetFilename = filename
        present(uploadNavigationController, animated: true)
        { () -> Void in
            uploadController.startUpload()
        }
    }
    
    @IBAction func refreshControlPulled(_ sender: AnyObject)
    {
        RemoteFileDatabaseHelper.refreshFromServer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "FileDetails"
        {
            let detailsViewController = segue.destination as! FileDetailsViewController
            detailsViewController.remoteFile = files[(tableView.indexPathForSelectedRow as NSIndexPath?)?.row ?? 0]
        }
    }
    
    // MARK : Table delegate/datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell") as! RemoteFileTableViewCell
        
        cell.update(files[(indexPath as NSIndexPath).row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            FileListClient(configuration: Configuration.updApiConfiguration).deleteFile(files[(indexPath as NSIndexPath).row],
                success: { () -> () in
                    self.files.remove(at: (indexPath as NSIndexPath).row)
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
                    RemoteFileDatabaseHelper.refreshFromServer()
                }, failure: { (error: NSError) -> () in
                    let alert = UIAlertController(title: "Error", message: "Couldn't delete file : \(error) \(error.userInfo)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            });
        }
    }
    
    // MARK : UIImagePickerController Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any])
    {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let url = info[UIImagePickerControllerReferenceURL] as! URL
        
        picker.dismiss(animated: true, completion: { () -> Void in
            ALAssetsLibrary().asset(for: url, resultBlock: { (asset: ALAsset?) -> Void in
                self.uploadImage(image, data: UIImageJPEGRepresentation(image, 1)!, filename: (asset!.defaultRepresentation().filename() as NSString).deletingPathExtension)
            }, failureBlock: { (error: Error?) -> Void in
                let error = error as? NSError
                let alert = UIAlertController(title: "Error", message: "Couldn't upload image : \(error) \(error?.userInfo)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        })
    }
    
    // MARK : UIViewControllerPreviewingDelegate
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController?
    {
        // Obtain the index path and the cell that was pressed.
        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier: "FileDetailsViewController") as? FileDetailsViewController else { return nil }
        
        previewingContext.sourceRect = cell.frame
        
        detailViewController.remoteFile = files[indexPath.row]
        
        return detailViewController
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController)
    {
        show(viewControllerToCommit, sender: self)
    }
}

class RemoteFileTableViewCell : UITableViewCell
{
    
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    
    func update(_ remoteFile : RemoteFile)
    {
        filenameLabel.text = remoteFile.filename
        dateLabel.text = remoteFile.uploadDate.timeAgoSinceNow
        //FIXME : Terrible, terrible method. FIX IT DAMNIT
        fileImageView.sd_setImage(with: URL(string: Configuration.endpoint + remoteFile.url + "?w=0&h=96")!)
    }
}

class FixedStatusBarImagePickerController : UIImagePickerController
{
    override var prefersStatusBarHidden : Bool
    {
        return false
    }
    
    override var childViewControllerForStatusBarHidden : UIViewController?
    {
        return nil
    }
}
