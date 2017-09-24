//
//  FileListClient.swift
//  Skugga
//
//  Created by Arnaud Barisain Monrose on 09/02/2015.
//
//

import Foundation

public struct FileListClient
{
    let config: UpdAPIConfiguration
    
    public init(configuration: UpdAPIConfiguration) {
        self.config = configuration
    }
    
    public func getFileList(_ success:@escaping ([RemoteFile]) -> (), failure:@escaping (NSError) -> ())
    {
        do {
            let request = try URLRequest(configuration: config, route: .List)
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, err: Error?) in
                if let httpErr = response?.httpError() {
                    failure(httpErr.nsError)
                    return
                }
                
                if let data = data, let files = try? JSONDecoder().decode(Array<RemoteFile>.self, from: data) {
                    success(files.sorted(by: {$0.uploadDate > $1.uploadDate}))
                } else {
                    if let err = err as NSError? {
                        failure(err)
                    } else {
                        failure(APIClientError.unknown.nsError)
                    }
                }
            }).resume()
        } catch let err as APIClientError {
            failure(err.nsError)
        } catch {
            failure(APIClientError.unknown.nsError)
        }
    }
    
    public func deleteFile(_ file: RemoteFile, success:@escaping () -> (), failure:@escaping (NSError) -> ())
    {
        do {
            var url = URL(string: config.endpoint)
            url?.appendPathComponent(file.url)
            url?.appendPathComponent(file.deleteKey)
            
            var request: URLRequest
            if let url = url {
                request = URLRequest(url: url)
                request.addSecret(config.secret)
            } else {
                throw APIClientError.badURL
            }
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, err: Error?) in
                
                if let httpErr = response?.httpError() {
                    failure(httpErr.nsError)
                    return
                }
                
                if err != nil {
                    if let err = err as NSError? {
                        failure(err)
                    } else {
                        failure(APIClientError.unknown.nsError)
                    }
                } else {
                    success()
                }
            }).resume()
        } catch let err as APIClientError {
            failure(err.nsError)
        } catch {
            failure(APIClientError.unknown.nsError)
        }
    }
}
