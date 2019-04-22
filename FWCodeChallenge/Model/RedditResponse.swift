//
//  RedditResponse.swift
//  FWCodeChallenge
//
//  Created by Edmund Holderbaum on 4/20/19.
//  Copyright © 2019 Dawn Trigger Enterprises. All rights reserved.
//

import Foundation

// I often group related objects, extensions, and protcols together in a file. I do this to keep the file structure from getting cluttered and when one grows more important or larger than the rest I separate it into another file.
// The JSON structure from the reddit API demanded many different objects be used for the sake of Codable. I pressed on using it because I really wanted to be make use of Swift 4's capabilities but in the future I would not use Codable for an API like this one.

struct RedditResponse: Codable {
    
    let kind: String
    let data: RedditResponseData
    
    // I like to make tools used specifically on a class static variables as you can see. I am a big fan of static variables and methods because they help keep code clean and organized without cluttering the memory.
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
