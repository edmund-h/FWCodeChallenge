//
//  RedditStory.swift
//  FWCodeChallenge
//
//  Created by Edmund Holderbaum on 4/20/19.
//  Copyright © 2019 Dawn Trigger Enterprises. All rights reserved.
//

import Foundation

struct RedditStory: Codable {
    
    let id: String
    let title: String
    let author: String
    let numComments: Int
    let createdUtc: Date
    let thumbnail: String?
    
    var imageUrl: String? {
        return thumbnail
    } //I thought having this one variable here would be better than making an entire set of coding keys just to have it differently named.
    
    var daysAgo: String {
        let interval =  Calendar.current.dateComponents([.day], from: createdUtc).value(for: .day)
        return "\(interval!) days ago"
    }
    
}
