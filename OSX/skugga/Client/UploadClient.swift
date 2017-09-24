
//  UploadWebservice.swift
//  skugga
//
//  Created by arnaud on 02/02/2015.
//
//

private let HEADER_FILENAME = "X-Upd-Orig-Filename"

import Foundation

struct UploadClient
{
    func upload(data: Data,
                filename: String,
                mimetype: String,
                progress:((_ bytesSent:Int64, _ bytesToSend:Int64) -> Void)?,
                success:@escaping ([AnyHashable: Any]) -> Void,
                failure:@escaping (NSError) -> Void) throws
    {
        /*return try uploadFile({ (formData: AFMultipartFormData?) -> Void in
            formData?.appendPart(withFileData: data, name: "data", fileName: filename, mimeType: mimetype)
            },
            filename: filename, progress: progress, success: success, failure: failure)*/
        
        return
    }
    
    func upload(file: URL,
                progress:((Float) -> Void)?, success:@escaping ([AnyHashable: Any]) -> Void, failure:@escaping (NSError) -> Void) throws
    {
        return
//        return try uploadFile({ (data: AFMultipartFormData?) -> Void in
//                do {
//                    try data?.appendPart(withFileURL: file, name: "data")
//                } catch {}
//            },
//            filename: file.lastPathComponent, progress: progress, success: success, failure: failure)
    }
    
    func upload(data: Data,
                filename: String,
                mimetype: String?,
                progress:((Double) -> Void)?,
                success:@escaping ([AnyHashable: Any]) -> Void,
                failure:@escaping (Error) -> Void) throws
    {
        var multipart = Multipart()
        try multipart.addFile(name: "data", filename: filename, mimetype: mimetype, data: data)
        
        guard let baseURL = URL(route: .Send) else { throw APIClientError.badURL }
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else { throw APIClientError.badURL }
        urlComponents.queryItems = [URLQueryItem(name: "name", value: filename)]
        guard let url = urlComponents.url else { throw APIClientError.badURL }
        
        var request = URLRequest(url: url)
        request.addSecret()
        request.setValue(filename, forHTTPHeaderField: HEADER_FILENAME)
        request = try multipart.multipartRequestWith(request: request)

        let progressCallback = progress ?? {(_) in }
        
        let delegate = URLSessionProgressDelegate(progressCallback: progressCallback)
        
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate: delegate,
                                 delegateQueue: OperationQueue.main)
        
        session.finishTasksAndInvalidate()
    }
}

@objc
class URLSessionProgressDelegate: NSObject, URLSessionTaskDelegate {
    
    let progressCallback: (_ progressPercentage: Double) -> Void
    
    init(progressCallback c: @escaping(_ progressPercentage: Double) -> Void) {
        self.progressCallback = c;
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        progressCallback(Double(totalBytesSent / totalBytesExpectedToSend))
    }
    
}
