//
//  TopStoriesViewModel.swift
//  FWCodeChallenge
//
//  Created by Edmund Holderbaum on 4/20/19.
//  Copyright © 2019 Dawn Trigger Enterprises. All rights reserved.
//

import UIKit

// This is one of my first attempts at an actual ViewModel and I had a lot of fun implementing it. It's easy to see why this paradigm has so many devotees.

class TopStoriesViewModel: NSObject, URLSessionDownloadDelegate {
    
    unowned var delegate: TopStoriesDelegate
    
    var stories: [RedditStory] = []
    var responses: [RedditResponseData] = []
    var images: [String: UIImage] = [:]
    var lastUpdate: Date?
    
    let loadingStoriesText = "Loading your stories... if this takes a long time please check your connection."
    
    var storyTableRowCount: Int {
        return stories.count
    }
    
    init(delegate: TopStoriesDelegate) {
        self.delegate = delegate
        super.init()
        getNewStories()
    }
    
    func getNewStories() {
        // I understand there is some contention about making web calls inside viewModels. Apparently Microsoft endorses using them in the viewModel and this could easily be moved out of the ViewModel and have the method passed in through the viewModel property by making handleResponseData public.
        RedditClient.getTopStories(then: handleResponseData(_:))
    }
    
    func getMoreStories() {
        guard let last = responses.last,
            let afterID = last.after else {
                return
        }
        
        RedditClient.getTopStories(after: afterID, then:
            handleResponseData(_:))
    }
    
    func getImage(for urlString: String)-> UIImage? {
        let image = images[urlString]
        if image == nil {
            // Self is passed in as a delegate for the download. See URLSessionDelegate.
            RedditClient.downloadImage(from: urlString, for: self)
        }
        return image
    }
    
    private func handleResponseData(_ response: RedditResponseData?) {
        guard let response = response else {
            print ("fail")
            return
        }
        
        lastUpdate = Date()
        
        self.responses.append(response)
        //I chose to make sure stories are unique because if a story goes up or down in rank before more stories are called for, the story could appear multiple times.
        response.stories.forEach({ story in
            if self.stories.contains(where: {story.id == $0.id}) == false {
                self.stories.append(story)
            }
        })
        
        print(stories)
        self.delegate.gotNewStories(self.stories)
    }
    
    func storyFor(indexPath: IndexPath)-> RedditStory {
        return stories[indexPath.row]
    }
    
    func labelFor(indexPath: IndexPath)-> String {
        guard indexPath.section == 0 else {
            var loadText = stories.count == 0 ? loadingStoriesText : "Tap here to get more top stories!"
            return loadText
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long
        if let lastUpdate = lastUpdate {
            let dateStr = dateFormatter.string(from: lastUpdate)
            let lastRefresh = "Last updated " + dateStr + ". \nTap to Refresh."
            return lastRefresh
        } else {
            return "No data"
        }
    }
    
    func imageFor(indexPath: IndexPath)-> UIImage {
        var image = #imageLiteral(resourceName: "redditLogo")
        guard let url = stories[indexPath.row].imageUrl else {
            return image
        }
        
        if let downloadedImage = getImage(for: url) {
            image = downloadedImage
        }
        
        return image
    }
    
    // MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        do {
            let data = try Data(contentsOf: location)
            
            guard let image = UIImage(data: data),
                let url = downloadTask.currentRequest?.url else {
                    return
            }
            
            DispatchQueue.main.async {
                self.images[url.absoluteString] = image
                self.delegate.gotImage(image, for: url.absoluteString)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

protocol TopStoriesDelegate: class {
    
    //I felt the protocol/delegate relationship went really well with the MVVM architecture. I set the delegate to unowned to prevent tight coupling.
    func gotNewStories(_ redditStories: [RedditStory])
    func gotImage(_ image: UIImage, for url: String)
    
}
