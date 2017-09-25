//
//  Configuration.swift
//  skugga
//
//  Created by Arnaud Barisain-Monrose on 08/02/2015.
//
//

import Foundation
import UpdAPI

private struct LocalConsts
{
    static let EndpointKey = "user.endpoint"
    static let SecretKey = "user.secret"
    static let SuffixKey = "user.suffix"
}

struct Configuration
{
    static var endpoint: String
    {
        get
        {
            return UserDefaults.standard.string(forKey: LocalConsts.EndpointKey) ?? ""
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: LocalConsts.EndpointKey)
        }
    }
    
    static var secret: String
    {
        get
        {
            return UserDefaults.standard.string(forKey: LocalConsts.SecretKey) ?? ""
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: LocalConsts.SecretKey)
        }
    }
    
    static var suffix: String
    {
        get
        {
            return UserDefaults.standard.string(forKey: LocalConsts.SuffixKey) ?? ""
        }
        
        set
        {
            UserDefaults.standard.set(newValue, forKey: LocalConsts.SuffixKey)
        }
    }
    
    static var updApiConfiguration: UpdAPIConfiguration
    {
        get
        {
            return UpdAPIConfiguration(endpoint: self.endpoint, secret: self.secret)
        }
    }
}
