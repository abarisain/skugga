//
//  FileListClient.swift
//  Skugga
//
//  Created by Arnaud Barisain Monrose on 09/02/2015.
//
//

let ROUTE_LIST = "1.0/list"

import Foundation

struct FileListClient
{
    func getFileList(success:([RemoteFile]) -> (), failure:(NSError) -> ())
    {
        
        let manager = AFHTTPSessionManager()
        
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.None)
        securityPolicy.allowInvalidCertificates = true
        manager.securityPolicy = securityPolicy
        
        let secret = Configuration.secret
        if (!secret.isEmpty)
        {
            manager.requestSerializer.setValue(secret, forHTTPHeaderField: ClientConsts.SECRET_KEY_HEADER)
        }
        else
        {
            manager.requestSerializer.setValue(nil, forHTTPHeaderField: ClientConsts.SECRET_KEY_HEADER)
        }
        
        let http =  AFJSONResponseSerializer()
        http.acceptableContentTypes = NSSet(object: ("text/plain")) as Set<NSObject>
        manager.responseSerializer = http
        
        _ = manager.GET(Configuration.endpoint + ROUTE_LIST,
            parameters: nil,
            success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
                if let clientFiles = responseObject as? [AnyObject]
                {
                    let files: [RemoteFile] = clientFiles.map({RemoteFile(fromNSDict: ($0 as! [NSObject:AnyObject]))}).sort({$0.uploadDate > $1.uploadDate})
                    success(files)
                }
                else
                {
                    failure(NSError(domain: ClientConsts.CLIENT_ERROR_DOMAIN, code: 1, userInfo: ["": "Error while parsing JSON answer"]))
                }
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
                failure(error)
            })
    }
    
    func deleteFile(file: RemoteFile, success:() -> (), failure:(NSError) -> ())
    {
        let manager = AFHTTPSessionManager()
        
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.None)
        securityPolicy.allowInvalidCertificates = true
        manager.securityPolicy = securityPolicy
        
        let secret = Configuration.secret
        if (!secret.isEmpty)
        {
            manager.requestSerializer.setValue(secret, forHTTPHeaderField: ClientConsts.SECRET_KEY_HEADER)
        }
        else
        {
            manager.requestSerializer.setValue(nil, forHTTPHeaderField: ClientConsts.SECRET_KEY_HEADER)
        }
        
        let http =  AFHTTPResponseSerializer()
        http.acceptableContentTypes = NSSet(object: ("text/plain")) as Set<NSObject>
        manager.responseSerializer = http
        
        _ = manager.GET(Configuration.endpoint + file.url + "/" + file.deleteKey,
            parameters: nil,
            success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
                success()
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
                failure(error)
        })
    }
}