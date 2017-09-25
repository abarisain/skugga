//
//  ClientConsts.swift
//  Skugga
//
//  Created by arnaud on 14/02/2015.
//
//

struct ClientConsts
{
    static let CLIENT_ERROR_DOMAIN = "SkuggaClientError"
    static let SECRET_KEY_HEADER = "X-Upd-Key"
}

enum Route: String {
    case List = "list"
    case Send = "send"
}
