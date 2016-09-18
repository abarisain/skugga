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
    func getFileList(_ success:@escaping ([RemoteFile]) -> (), failure:@escaping (NSError) -> ())
    {
        
        let manager = AFHTTPSessionManager()
        
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
        securityPolicy?.allowInvalidCertificates = true
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
        http?.acceptableContentTypes = NSSet(object: ("text/plain")) as Set<NSObject>
        manager.responseSerializer = http
        
        _ = manager.get(Configuration.endpoint + ROUTE_LIST,
            parameters: nil,
            success: { (task: URLSessionDataTask?, responseObject: Any?) -> Void in
                if let clientFiles = responseObject as? [AnyObject]
                {
                    let files: [RemoteFile] = clientFiles.map({RemoteFile(fromNSDict: ($0 as! [AnyHashable: Any]))}).sorted(by: {$0.uploadDate > $1.uploadDate})
                    success(files)
                }
                else
                {
                    failure(NSError(domain: ClientConsts.CLIENT_ERROR_DOMAIN, code: 1, userInfo: ["": "Error while parsing JSON answer"]))
                }
            }, failure: { (task: URLSessionDataTask?, error: Error?) -> Void in
                failure(error as NSError!)
            })
    }
    
    func deleteFile(_ file: RemoteFile, success:@escaping () -> (), failure:@escaping (NSError) -> ())
    {
        let manager = AFHTTPSessionManager()
        
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
        securityPolicy?.allowInvalidCertificates = true
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
        http?.acceptableContentTypes = NSSet(object: ("text/plain")) as Set<NSObject>
        manager.responseSerializer = http
        
        _ = manager.get(Configuration.endpoint + file.url + "/" + file.deleteKey,
            parameters: nil,
            success: { (task: URLSessionDataTask?, responseObject: Any?) -> Void in
                success()
            }, failure: { (task: URLSessionDataTask?, error: Error?) -> Void in
                failure(error as NSError!)
        })
    }
}
