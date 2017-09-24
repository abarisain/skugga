//
//  Multipart.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 23/09/2017.
//  Copyright © 2017 NamelessDev. All rights reserved.
//

import Foundation

private let crlf = "\r\n"

enum MultipartError: Error {
    case encodingError
    case alreadyFinishedError
    case notFinishedError
}

// Multipart data builder
// The data must fit in RAM
// Only UTF-8 is supported
public struct Multipart {
    let boundary = "skugga_" + UUID().uuidString
    var finished = false
    var data = Data()
    
    mutating func addFile(name: String, filename: String, data fileData: Data) throws {
        try appendBoundaryStart()
        let safeName = Multipart.safeStringForDataParameter(name)
        let safeFilename = Multipart.safeStringForDataParameter(filename)
        try appendLine("Content-Disposition: form-data; name=\"\(safeName)\"; filename=\"\(safeFilename)\"")
        try appendLine("Content-Type: application/octet-stream")
        data += fileData
    }
    
    mutating func finish() throws {
        try appendBoundaryEnd()
        finished = true
    }
    
    func multipartRequestWith(request r: URLRequest) throws -> URLRequest {
        if !finished {
            throw MultipartError.notFinishedError
        }
        
        var request = r
        request.setValue(String(data.count), forHTTPHeaderField: "Content-Length")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        return request
    }
}

extension Multipart {
    
    mutating func appendBoundaryStart() throws {
        try append(string: "--" + self.boundary + crlf)
    }
    
    mutating func appendBoundaryEnd() throws {
        try append(string: "--" + self.boundary + "--" + crlf)
    }
    
    mutating func appendLine(_ string: String) throws {
        try append(string: string + crlf)
    }
    
    mutating func append(string: String) throws {
        if finished {
            throw MultipartError.alreadyFinishedError
        }
        
        if let stringData = string.data(using: .utf8) {
            data += stringData
        } else {
            throw MultipartError.encodingError
        }
    }
    
    static func safeStringForDataParameter(_ string: String) -> String {
        return string.replacingOccurrences(of: "\"", with: "_")
    }
}
