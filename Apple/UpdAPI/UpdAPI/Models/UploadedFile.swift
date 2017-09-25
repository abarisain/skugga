//
//  UploadedFile.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 24/09/2017.
//  Copyright © 2017 NamelessDev. All rights reserved.
//

import Foundation

public struct UploadedFile: Codable {
    public let url: String
    
    enum CodingKeys: String, CodingKey {
        case url = "name"
    }
}
