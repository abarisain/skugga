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
        
        var manager = AFHTTPSessionManager();
        
        var securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.None);
        securityPolicy.allowInvalidCertificates = true;
        manager.securityPolicy = securityPolicy;
        
        let secret = Configuration.secret;
        if (!secret.isEmpty)
        {
            manager.requestSerializer.setValue(secret, forHTTPHeaderField: Consts.SECRET_KEY_HEADER)
        }
        else
        {
            manager.requestSerializer.setValue(nil, forHTTPHeaderField: Consts.SECRET_KEY_HEADER)
        }
        
        var http =  AFJSONResponseSerializer();
        http.acceptableContentTypes = NSSet(object: ("text/plain"));
        manager.responseSerializer = http;
        
        var getTask = manager.GET(Configuration.endpoint + ROUTE_LIST,
            parameters: nil,
            success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) -> Void in
                NSLog("%@", (responseObject as NSArray).description);
                if let clientFiles = responseObject as? [AnyObject]
                {
                    var files: [RemoteFile] = clientFiles.map({RemoteFile(fromNSDict: ($0 as [NSObject:AnyObject]))});
                    success(files);
                }
                else
                {
                    failure(NSError(domain: Consts.CLIENT_ERROR_DOMAIN, code: 1, userInfo: ["": "Error while parsing JSON answer"]));
                }
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
                failure(error);
            });
    }
}