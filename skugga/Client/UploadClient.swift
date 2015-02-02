//
//  UploadWebservice.swift
//  skugga
//
//  Created by arnaud on 02/02/2015.
//
//

let DEBUG_URL = "http://localhost:9000/"

let ROUTE_SEND = "/1.0/send"

import Foundation

class UploadClient
{
    func uploadFile(file: NSURL, progress:((bytesSent:Int64, bytesToSend:Int64) -> Void)?, success:([NSObject:AnyObject]) -> Void, failure:(NSError) -> Void) -> (success: Bool, error: NSError?)
    {
        var manager = AFHTTPSessionManager();
        
        manager.setTaskDidSendBodyDataBlock({ (session: NSURLSession!, task: NSURLSessionTask!, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
            if let safeProgress = progress?
            {
                safeProgress(bytesSent: totalBytesSent, bytesToSend: totalBytesExpectedToSend);
            }
        });
        
        var error :NSError?;
        
        var request = AFHTTPRequestSerializer().multipartFormRequestWithMethod("POST",
            URLString: DEBUG_URL + ROUTE_SEND,
            parameters: nil,
            constructingBodyWithBlock: { (data: AFMultipartFormData!) -> Void in
                var error :NSError?;
                data.appendPartWithFileURL(file, name: file.lastPathComponent, error: &error);
            },
            error: &error)
        
        var uploadTask = manager.uploadTaskWithStreamedRequest(request,
            progress: nil,
            completionHandler: { (response: NSURLResponse!, responseObject: AnyObject!, error: NSError!) -> Void in
                let httpResponse = response as NSHTTPURLResponse;
                if (httpResponse.statusCode == 200)
                {
                    success(responseObject as [NSObject:AnyObject]);
                }
                else
                {
                    failure(NSError(domain: ClientConsts.CLIENT_ERROR_DOMAIN, code: 1, userInfo: ["": "Error while uploading file", "statusCode": httpResponse.statusCode]));
                }

            }
        );
        
        if (error != nil)
        {
            return (false, error);
        }
        
        uploadTask.resume();
        
        return (true, nil);
    }
}