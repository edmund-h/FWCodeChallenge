//
//  StoryCell.swift
//  FWCodeChallenge
//
//  Created by Edmund Holderbaum on 4/21/19.
//  Copyright © 2019 Dawn Trigger Enterprises. All rights reserved.
//

import UIKit

class StoryCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var story: RedditStory? {
        didSet {
            guard let story = story else {
                return
            }
            
            titleLabel.text = story.title
            infoLabel.text = "posted by \(story.author), \(story.daysAgo). \(story.numComments) comments."
            favoriteButton.isHidden = story.thumbnail == nil
        }
    }
    
    static let loveNotification = Notification.Name.init(rawValue: "LoveTapped")
    
    @IBAction func favoriteTapped(_ sender: Any) {
        guard let url = story?.thumbnail else {
            return
        }
        
        NotificationCenter.default.post(name: StoryCell.loveNotification , object: nil, userInfo: [StoryCell.loveNotification:url])
    }
}
