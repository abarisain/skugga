//
//  RemoteFile.swift
//  Skugga
//
//  Created by Arnaud Barisain Monrose on 09/02/2015.
//
//

import Foundation

struct RemoteFile
{
    var filename: String;
    var uploadDate: NSDate;
    var url: String;
    var deleteKey: String;
    
    init(fromNSDict dict: [NSObject: AnyObject])
    {
        filename = dict["original"] as? String ?? "<unknown original name>";
        uploadDate = NSDate(); // FIXME : Really parse the date
        url = dict["name"] as String;
        deleteKey = dict["delete_key"] as String;
    }
}