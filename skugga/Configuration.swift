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
}

struct Configuration
{
    static var endpoint: String
    {
        get
        {
            return NSUserDefaults.standardUserDefaults().stringForKey(LocalConsts.EndpointKey) ?? "";
        }
        
        set
        {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: LocalConsts.EndpointKey);
        }
    }
    
    static var secret: String
    {
        get
        {
            return NSUserDefaults.standardUserDefaults().stringForKey(LocalConsts.SecretKey) ?? "";
        }
        
        set
        {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: LocalConsts.SecretKey);
        }
    }
}