//
//  TopStoriesViewController.swift
//  FWCodeChallenge
//
//  Created by Edmund Holderbaum on 4/18/19.
//  Copyright © 2019 Dawn Trigger Enterprises. All rights reserved.
//

import UIKit

class TopStoriesViewController: UIViewController {
    
    @IBOutlet weak var storyTable: UITableView!
    
    var viewModel: TopStoriesViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel = TopStoriesViewModel(delegate: self)
        storyTable.rowHeight = UITableView.automaticDimension
        let name = StoryCell.loveNotification
        NotificationCenter.default.addObserver(self, selector: #selector(showShareController(_:)), name: name, object: nil)
    }
    
    @objc func showShareController(_ notification: Notification) {
        guard let url = notification.userInfo?[notification.name] as? String,
            let img = viewModel?.images[url] else {
            return
        }
        
        let shareController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        shareController.title = "Share or Save Image"
        shareController.completionWithItemsHandler = { type, _, _, error in
            var ac = UIAlertController(title: "Success!", message: "Selected action was successful!", preferredStyle: .alert)
            
            if let _ = error {
                ac = UIAlertController(title: "Error", message: "Selected action failed.", preferredStyle: .alert)
            }
            let okButton = UIAlertAction(title: "OK", style: .default, handler: { _ in
                ac.dismiss(animated: true, completion: nil)
            })
            ac.addAction(okButton)
            self.present(ac, animated: true)
        }
        
        self.present(shareController, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            // we got back an error!
            let ac = UIAlertController(title: "An error occurred", message: "We're sorry, an error occurred with the requested action", preferredStyle: .alert)
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Image Saved!", message: "Successfully saved image!", preferredStyle: .alert)
            present(ac, animated: true)
        }
    }
}

extension TopStoriesViewController: TopStoriesDelegate {
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

extension TopStoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            let cell = tableView.cellForRow(at: indexPath) as! UtilityCell
            cell.label.text = viewModel?.loadingStoriesText
            viewModel?.getMoreStories()
        }
    }

}
