//
//  FileListClient.swift
//  Skugga
//
//  Created by Arnaud Barisain Monrose on 09/02/2015.
//
//

import Foundation
import AFNetworking

struct FileListClient
{
    func getFileList(_ success:@escaping ([RemoteFile]) -> (), failure:@escaping (NSError) -> ())
    {
        do {
            let request = try URLRequest(route: .List)
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, err: Error?) in
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
    
    func deleteFile(_ file: RemoteFile, success:@escaping () -> (), failure:@escaping (NSError) -> ())
    {
        do {
            var url = URL(string: Configuration.endpoint)
            url?.appendPathComponent(file.url)
            url?.appendPathComponent(file.deleteKey)
            
            var request: URLRequest
            if let url = url {
                request = URLRequest(url: url)
                request.addSecret()
            } else {
                throw APIClientError.badURL
            }
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, err: Error?) in
                
                
                
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
