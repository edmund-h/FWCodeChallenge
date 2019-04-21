//
//  ViewController.swift
//  FWCodeChallenge
//
//  Created by Edmund Holderbaum on 4/18/19.
//  Copyright © 2019 Dawn Trigger Enterprises. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var storyTable: UITableView!
    
    var viewModel: TopStoriesViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel = TopStoriesViewModel(delegate: self)
        storyTable.rowHeight = UITableView.automaticDimension
    }
    
}

extension ViewController: TopStoriesDelegate {
    func gotNewStories(_ redditStories: [RedditStory]) {
        print("gotNewStories")
        DispatchQueue.main.async {
            self.storyTable.reloadData()
        }
    }
    
    func gotImage(_ image: UIImage, for url: String) {
        guard let cellPaths = storyTable.indexPathsForVisibleRows else {
            return
        }
        
        for path in cellPaths {
            //check if visible story got an image
            if viewModel?.stories[path.row].imageUrl == url, let cell =
                storyTable.cellForRow(at: path) as? StoryCell {
                cell.storyImage.image = image
                return
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let storyCount = viewModel?.storyTableRowCount ?? 0
        return section == 1 ? storyCount : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 1 else {
            let cell = storyTable.dequeueReusableCell(withIdentifier: "utilityCell") as! UtilityCell
            cell.label.text = viewModel?.labelFor(indexPath: indexPath)
            return cell
        }
        let cell = storyTable.dequeueReusableCell(withIdentifier: "storyCell") as! StoryCell
        cell.story = viewModel?.storyFor(indexPath: indexPath)
        cell.storyImage.image = viewModel?.imageFor(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.viewModel = nil
            self.viewModel = TopStoriesViewModel(delegate: self)
        } else if indexPath.section == 2 {
            viewModel?.getMoreStories()
        }
    }

}
