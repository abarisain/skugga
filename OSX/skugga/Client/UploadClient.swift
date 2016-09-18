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
    func uploadFile(_ data: Data, filename: String, mimetype: String, progress:((_ bytesSent:Int64, _ bytesToSend:Int64) -> Void)?, success:@escaping ([AnyHashable: Any]) -> Void, failure:@escaping (NSError) -> Void) throws -> Bool
    {
        return try uploadFile({ (formData: AFMultipartFormData!) -> Void in
            formData.appendPart(withFileData: data, name: "data", fileName: filename, mimeType: mimetype)
            } as! (AFMultipartFormData?) -> Void,
            filename: filename, progress: progress, success: success, failure: failure)
    }
    
    func uploadFile(_ file: URL, progress:((_ bytesSent:Int64, _ bytesToSend:Int64) -> Void)?, success:@escaping ([AnyHashable: Any]) -> Void, failure:@escaping (NSError) -> Void) throws -> Bool
    {
        return try uploadFile({ (data: AFMultipartFormData?) -> Void in
                do {
                    try data?.appendPart(withFileURL: file, name: "data")
                } catch {}
            },
            filename: file.lastPathComponent, progress: progress, success: success, failure: failure)
    }
    
    fileprivate func uploadFile(_ bodyBlock:@escaping (_ data: AFMultipartFormData?) -> Void, filename: String, progress:((_ bytesSent:Int64, _ bytesToSend:Int64) -> Void)?, success:@escaping ([AnyHashable: Any]) -> Void, failure:@escaping (NSError) -> Void) throws -> Bool
    {
        let manager = AFHTTPSessionManager()
        
        manager.setTaskDidSendBodyDataBlock({ (session: URLSession?, task: URLSessionTask?, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
            progress?(totalBytesSent, totalBytesExpectedToSend)
        })
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
        securityPolicy?.allowInvalidCertificates = true
        manager.securityPolicy = securityPolicy
        
        var request: NSMutableURLRequest!
        request = AFHTTPRequestSerializer().multipartFormRequest(withMethod: "POST",
            urlString: Configuration.endpoint + ROUTE_SEND + "?name=" + filename.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            parameters: nil,
            constructingBodyWith: bodyBlock)
        
        request.addValue(filename, forHTTPHeaderField: HEADER_FILENAME)
        
        let secret = Configuration.secret
        if (!secret.isEmpty)
        {
            request.addValue(secret, forHTTPHeaderField: ClientConsts.SECRET_KEY_HEADER)
        }
        
        let uploadTask = manager.uploadTask(withStreamedRequest: request as URLRequest!,
            progress: nil,
            completionHandler: { (response: URLResponse?, responseObject: Any?, error: Error?) -> Void in
                if let error = error
                {
                    failure(error as NSError)
                }
                else
                {
                    let httpResponse = response as! HTTPURLResponse
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
        
        uploadTask?.resume()
        
        return true
    }
}
