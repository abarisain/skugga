
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
    func upload(file: URL,
                progress:((Double) -> Void)?,
                success:@escaping ([AnyHashable: Any]) -> Void,
                failure:@escaping (Error) -> Void) throws
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
                success:@escaping (UploadedFile) -> Void,
                failure:@escaping (Error) -> Void) throws
    {
        var multipart = Multipart()
        try multipart.addFile(name: "data", filename: filename, mimetype: mimetype, data: data)
        try multipart.finish()
        
        guard let baseURL = URL(route: .Send) else { throw APIClientError.badURL }
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else { throw APIClientError.badURL }
        urlComponents.queryItems = [URLQueryItem(name: "name", value: filename)]
        guard let url = urlComponents.url else { throw APIClientError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addSecret()
        request.setValue(filename, forHTTPHeaderField: HEADER_FILENAME)
        request = try multipart.multipartRequestWith(request: request)

        let progressCallback = progress ?? {(_) in }
        
        let delegate = URLSessionProgressDelegate(progressCallback: progressCallback)
        
        let session = URLSession(configuration: URLSessionConfiguration.default,
                                 delegate: delegate,
                                 delegateQueue: OperationQueue.main)
        
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, err: Error?) in
            if let err = err {
                failure(err)
                return
            }
            
            if let httpErr = response?.httpError() {
                failure(httpErr)
                return
            }
            
            if let data = data,
                let file = try? JSONDecoder().decode(UploadedFile.self, from: data) {
                success(file);
            } else {
                failure(APIClientError.jsonParserError)
            }
        }.resume()
        
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
