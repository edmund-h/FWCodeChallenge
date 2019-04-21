//
//  RedditResponse.swift
//  FWCodeChallenge
//
//  Created by Edmund Holderbaum on 4/20/19.
//  Copyright © 2019 Dawn Trigger Enterprises. All rights reserved.
//

import Foundation

struct RedditResponse: Codable {
    
    let kind: String
    let data: RedditResponseData
    
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
    
}

struct RedditResponseData: Codable {
    
    let children: [RedditResponseChild]
    let after: String?
    let before: String?
    
    var stories: [RedditStory] {
        return children.map({$0.data})
    }
}

struct RedditResponseChild: Codable {
    
    let kind: String
    let data: RedditStory
}
