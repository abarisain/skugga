//
//  UpdAPIConfiguration.swift
//  UpdAPI
//
//  Created by Arnaud Barisain-Monrose on 24/09/2017.
//  Copyright © 2017 NamelessDev. All rights reserved.
//

import Foundation

public struct UpdAPIConfiguration {
    let endpoint: String
    let secret: String?
    
    public init(endpoint: String, secret: String?) {
        self.endpoint = endpoint
        self.secret = secret
    }
}
