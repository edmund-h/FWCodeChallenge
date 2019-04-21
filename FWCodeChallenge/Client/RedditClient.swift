//
//  RedditClient.swift
//  FWCodeChallenge
//
//  Created by Edmund Holderbaum on 4/18/19.
//  Copyright © 2019 Dawn Trigger Enterprises. All rights reserved.
//

import Foundation

typealias RedditResponseCompletion = (RedditResponseData?)->()

final class RedditClient {
    
    static func getTopStories(after: String? = nil, then completion: @escaping RedditResponseCompletion) {
        
        let urlSession = URLSession(configuration: .default)
        
        var dataTask: URLSessionDataTask?
        let urlStr = "https://api.reddit.com/top"
        let query = after != nil ? "?after=\(after!)" : ""
        
        guard let url = URL(string: urlStr + query) else {
            completion(nil)
            return
        }
        
        dataTask = urlSession.dataTask(with: url) { data, urlResponse, error in
            guard error == nil,
                let response = urlResponse as? HTTPURLResponse,
                response.statusCode == 200, let data = data else {
                print(error?.localizedDescription ?? "RedditClient: No Response")
                completion(nil)
                return
            }
            
            let responseData = handle(response: data)
            completion(responseData)
        }
        
        dataTask?.resume()
    }
    
    static func downloadImage(from urlStr: String, for delegate: URLSessionDownloadDelegate) {
        let urlSession = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        
        guard let url = URL(string: urlStr) else {
            return
        }
        
        let task = urlSession.downloadTask(with: url)
        task.resume()
    }
    
    static func handle(response data: Data)-> RedditResponseData? {
        let redditDecoder = RedditResponse.decoder
        do {
            let redditResponse = try redditDecoder.decode(RedditResponse.self, from: data)
            
            if redditResponse.data.children.isEmpty {
                return nil
            }
            
            return redditResponse.data
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
