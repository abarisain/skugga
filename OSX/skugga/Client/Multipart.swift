//
//  Multipart.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 23/09/2017.
//  Copyright © 2017 NamelessDev. All rights reserved.
//

import Foundation

private let linefeed = "\r\n"

enum MultipartError: Error {
    case encodingError
}

// Multipart data builder
// The data must fit in RAM
// Only UTF-8 is supported
struct Multipart {
    let boundary = "skugga_" + UUID().uuidString
    var data = Data()
}

extension Multipart {
    mutating func appendLine(_ string: String) throws {
        if let stringData = (string + linefeed).data(using: .utf8) {
            data += stringData
        } else {
            throw MultipartError.encodingError
        }
    }
}
