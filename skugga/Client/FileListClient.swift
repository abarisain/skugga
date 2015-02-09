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
                NSLog("%@", responseObject as NSDictionary);
            }, failure: { (task: NSURLSessionDataTask!, error: NSError!) -> Void in
                failure(error);
            });
    }
}