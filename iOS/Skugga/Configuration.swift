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
    static let EndpointKey = "user.endpoint";
    static let SecretKey = "user.secret";
    static let GroupId = "group.fr.nlss.skugga";
}

struct Configuration
{
    static var endpoint: String
    {
        get
        {
            return NSUserDefaults(suiteName: "lel")?.stringForKey(LocalConsts.EndpointKey) ?? "";
        }
        
        set
        {
            NSUserDefaults(suiteName: "lel")?.setObject(newValue, forKey: LocalConsts.EndpointKey);
        }
    }
    
    static var secret: String
    {
        get
        {
            return NSUserDefaults(suiteName: "lel")?.stringForKey(LocalConsts.SecretKey) ?? "";
        }
        
        set
        {
            NSUserDefaults(suiteName: "lel")?.setObject(newValue, forKey: LocalConsts.SecretKey);
        }
    }
}