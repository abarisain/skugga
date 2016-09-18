//
//  Configuration.swift
//  skugga
//
//  Created by Arnaud Barisain-Monrose on 08/02/2015.
//
//

import Foundation

private struct LocalConsts
{
    static let EndpointKey = "user.endpoint"
    static let SecretKey = "user.secret"
    static let GroupId = "group.fr.nlss.skugga"
}

struct Configuration
{
    static var endpoint: String
    {
        get
        {
            return UserDefaults(suiteName: LocalConsts.GroupId)?.string(forKey: LocalConsts.EndpointKey) ?? ""
        }
        
        set
        {
            UserDefaults(suiteName: LocalConsts.GroupId)?.set(newValue, forKey: LocalConsts.EndpointKey)
        }
    }
    
    static var secret: String
    {
        get
        {
            return UserDefaults(suiteName: LocalConsts.GroupId)?.string(forKey: LocalConsts.SecretKey) ?? ""
        }
        
        set
        {
            UserDefaults(suiteName: LocalConsts.GroupId)?.set(newValue, forKey: LocalConsts.SecretKey)
        }
    }
    
    static func synchronize()
    {
        UserDefaults(suiteName: LocalConsts.GroupId)?.synchronize()
    }
}
