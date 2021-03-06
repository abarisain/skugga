//
//  ClientUtils.swift
//  Skugga
//
//  Created by Arnaud Barisain-Monrose on 23/09/2017.
//  Copyright © 2017 NamelessDev. All rights reserved.
//

import Foundation

public enum APIClientError: Error, LocalizedError {
    case unknown
    case badURL
    case jsonParserError
    case httpError(code: Int)
    
    var errorDescription: String {
        switch(self) {
        case .unknown: return "Unknown"
        case .badURL: return "Bad URL"
        case .jsonParserError: return "JSON Parsing error"
        case .httpError: return "Bad HTTP Status Code: \(self.code)"
        }
    }
    
    var code: Int {
        switch(self) {
        case .unknown: return -1
        case .badURL: return 1
        case .jsonParserError: return 2
        case .httpError: return 3
        }
    }
    
    var nsError: NSError {
        return NSError(domain: "skugga.apiclient.error", code: self.code, userInfo: [NSLocalizedDescriptionKey: self.errorDescription ?? "Unknown"])
    }
}

extension URL {
    init?(configuration: UpdAPIConfiguration, route: Route?) {
        self.init(string: configuration.endpoint)
        self.appendPathComponent("1.0")
        if let route = route {
            self.appendPathComponent(route.rawValue)
        }
    }
}

extension URLRequest {
    init(configuration: UpdAPIConfiguration, route: Route?) throws {
        let url = URL(configuration: configuration, route: route)
        
        if let url = url {
            self.init(url: url)
            addSecret(configuration.secret)
        } else {
            throw APIClientError.badURL
        }
    }
    
    mutating func addSecret(_ secret: String?) {
        if let secret = secret {
            self.setValue(secret, forHTTPHeaderField: ClientConsts.SECRET_KEY_HEADER)
        }
    }
}

extension URLResponse {
    func httpError() -> APIClientError? {
        if let statusCode = (self as? HTTPURLResponse)?.statusCode,
            statusCode < 200 || statusCode > 299 {
            return APIClientError.httpError(code: statusCode)
        }
        return nil
    }
}
