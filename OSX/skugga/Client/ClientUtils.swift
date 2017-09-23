//
//  ClientUtils.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 23/09/2017.
//  Copyright © 2017 NamelessDev. All rights reserved.
//

import Foundation

enum APIClientError: String, Error, LocalizedError {
    case unknown = "Unknown"
    case badURL = "Bad URL"
    case jsonParserError = "JSON Parsing error"
    
    var errorDescription: String {
        return self.rawValue
    }
    
    var code: Int {
        switch(self) {
        case .unknown: return -1
        case .badURL: return 1
        case .jsonParserError: return 2
        }
    }
    
    var nsError: NSError {
        return NSError(domain: "skugga.apiclient.error", code: self.code, userInfo: [NSLocalizedDescriptionKey: self.rawValue.description])
    }
}

extension URLRequest {
    init(route: Route?) throws {
        var url = URL(string: Configuration.endpoint)
        url?.appendPathComponent("1.0")
        if let route = route {
            url?.appendPathComponent(route.rawValue)
        }
        
        if let url = url {
            self.init(url: url)
            
            let secret = Configuration.secret
            if !secret.isEmpty {
                self.setValue(secret, forHTTPHeaderField: ClientConsts.SECRET_KEY_HEADER)
            }
        } else {
            throw APIClientError.badURL
        }
    }
    
    mutating func addSecret() {
        let secret = Configuration.secret
        if !secret.isEmpty {
            self.setValue(secret, forHTTPHeaderField: ClientConsts.SECRET_KEY_HEADER)
        }
    }
}
