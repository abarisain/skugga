//
//  UploadWebservice.swift
//  skugga
//
//  Created by arnaud on 02/02/2015.
//
//

let ROUTE_SEND = "1.0/send"

let HEADER_FILENAME = "X-Upd-Orig-Filename"

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
            URLString: ClientConsts.DEBUG_URL + ROUTE_SEND + "?name=" + file.lastPathComponent!.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!,
            parameters: nil,
            constructingBodyWithBlock: { (data: AFMultipartFormData!) -> Void in
                var error :NSError?;
                data.appendPartWithFileURL(file, name: "data", error: &error);
            },
            error: &error)
        
        request.addValue(file.lastPathComponent, forHTTPHeaderField: HEADER_FILENAME);
        
        // Todo : make this more generic. Maybe.
        if (!ClientConsts.SECRET_KEY.isEmpty)
        {
            request.addValue(ClientConsts.SECRET_KEY, forHTTPHeaderField: ClientConsts.SECRET_KEY_HEADER);
        }
        
        var uploadTask = manager.uploadTaskWithStreamedRequest(request,
            progress: nil,
            completionHandler: { (response: NSURLResponse!, responseObject: AnyObject!, error: NSError!) -> Void in
                let httpResponse = response as NSHTTPURLResponse;
                if (httpResponse.statusCode == 200)
                {
                    success(responseObject as Dictionary);
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