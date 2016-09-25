//
//  PhotoHelper.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 25/09/2016.
//  Copyright © 2016 NamelessDev. All rights reserved.
//

import Foundation
import Photos

class PhotoHelper {
    func lastTakenPhoto(completionHandler: @escaping (_ image: UIImage?, _ filename: String?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        if let asset = PHAsset.fetchAssets(with: .image, options: fetchOptions).firstObject {
            let requestOptions = PHImageRequestOptions()
            requestOptions.isNetworkAccessAllowed = true
            PHImageManager.default().requestImageData(for: asset, options: requestOptions, resultHandler: { (data: Data?, uti: String?, orientation: UIImageOrientation, info: [AnyHashable : Any]?) in
                if let data = data, let image = UIImage(data: data) {
                    // Read an undocumented key to get the filename
                    var filename: String?
                    if let fileURL = info?["PHImageFileURLKey"] as? URL {
                        filename = fileURL.lastPathComponent
                    }
                    
                    completionHandler(image, filename)
                } else {
                    completionHandler(nil, nil)
                }
            })
        } else {
            completionHandler(nil, nil)
        }
    }
    
    func uploadLastTakenPhoto() {
        lastTakenPhoto { (photo: UIImage?, filename: String?) in
            if var vc = UIApplication.shared.keyWindow?.rootViewController {
                if let presentedVC = vc.presentedViewController {
                    vc = presentedVC
                }
                
                if let photo = photo {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let uploadNavigationController = storyboard.instantiateViewController(withIdentifier: "UploadScene") as! UINavigationController
                    let uploadController = uploadNavigationController.viewControllers[0] as! UploadViewController
                    uploadController.targetImage = photo
                    uploadController.targetData = UIImageJPEGRepresentation(photo, 1.0)!
                    uploadController.targetFilename = filename ?? "Unknown"
                    
                    vc.present(uploadNavigationController, animated: true, completion: {
                        uploadController.startUpload()
                    })
                } else {
                    let alert = UIAlertController(title: "Internal error", message: "An unknown error occurred when trying to upload the last taken photo.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    vc.present(vc, animated: true, completion: nil)
                }
            } else {
                // It would be great to create an empty uiwindow and show the alert here
            }
        }
    }
}
