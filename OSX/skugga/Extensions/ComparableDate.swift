//
//  ComparableDate.swift
//  Skugga
//
//  Created by arnaud on 14/02/2015.
//  Copyright (c) 2015 NamelessDev. All rights reserved.
//

extension NSDate: Comparable { }

public func <(a: NSDate, b: NSDate) -> Bool
{
    return a.compare(b) == NSComparisonResult.OrderedAscending
}

public func ==(a: NSDate, b: NSDate) -> Bool
{
    return a.compare(b) == NSComparisonResult.OrderedSame
}