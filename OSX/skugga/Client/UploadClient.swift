//
//  UploadWebservice.swift
//  skugga
//
//  Created by arnaud on 02/02/2015.
//
//

private let ROUTE_SEND = "1.0/send"

private let HEADER_FILENAME = "X-Upd-Orig-Filename"

import Foundation

struct UploadClient
{
    func uploadFile(data: NSData, filename: String, mimetype: String, progress:((bytesSent:Int64, bytesToSend:Int64) -> Void)?, success:([NSObject:AnyObject]) -> Void, failure:(NSError) -> Void) throws -> Bool
    {
        return try uploadFile({ (formData: AFMultipartFormData!) -> Void in
            formData.appendPartWithFileData(data, name: "data", fileName: filename, mimeType: mimetype)
            },
            filename: filename, progress: progress, success: success, failure: failure)
    }
    
    func uploadFile(file: NSURL, progress:((bytesSent:Int64, bytesToSend:Int64) -> Void)?, success:([NSObject:AnyObject]) -> Void, failure:(NSError) -> Void) throws -> Bool
    {
        return try uploadFile({ (data: AFMultipartFormData!) -> Void in
                do {
                    try data.appendPartWithFileURL(file, name: "data")
                } catch {}
            },
            filename: file.lastPathComponent!, progress: progress, success: success, failure: failure)
    }
    
    private func uploadFile(bodyBlock:(data: AFMultipartFormData!) -> Void, filename: String, progress:((bytesSent:Int64, bytesToSend:Int64) -> Void)?, success:([NSObject:AnyObject]) -> Void, failure:(NSError) -> Void) throws -> Bool
    {
        let manager = AFHTTPSessionManager()
        
        manager.setTaskDidSendBodyDataBlock({ (session: NSURLSession!, task: NSURLSessionTask!, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
            if let safeProgress = progress
            {
                safeProgress(bytesSent: totalBytesSent, bytesToSend: totalBytesExpectedToSend)
            }
        })
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.None)
        securityPolicy.allowInvalidCertificates = true
        manager.securityPolicy = securityPolicy
        
        
        var request: NSMutableURLRequest!
        request = AFHTTPRequestSerializer().multipartFormRequestWithMethod("POST",
            URLString: Configuration.endpoint + ROUTE_SEND + "?name=" + filename.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!,
            parameters: nil,
            constructingBodyWithBlock: bodyBlock)
        
        request.addValue(filename, forHTTPHeaderField: HEADER_FILENAME)
        
        let secret = Configuration.secret
        if (!secret.isEmpty)
        {
            request.addValue(secret, forHTTPHeaderField: ClientConsts.SECRET_KEY_HEADER)
        }
        
        let uploadTask = manager.uploadTaskWithStreamedRequest(request,
            progress: nil,
            completionHandler: { (response: NSURLResponse!, responseObject: AnyObject!, error: NSError!) -> Void in
                if let error = error
                {
                    failure(error)
                }
                else
                {
                    let httpResponse = response as! NSHTTPURLResponse
                    if (httpResponse.statusCode == 200)
                    {
                        success(responseObject as! Dictionary)
                    }
                    else
                    {
                        failure(NSError(domain: ClientConsts.CLIENT_ERROR_DOMAIN, code: 1, userInfo: ["": "Error while uploading file", "statusCode": httpResponse.statusCode]))
                    }
                }

            }
        )
        
        uploadTask.resume()
        
        return true
    }
}