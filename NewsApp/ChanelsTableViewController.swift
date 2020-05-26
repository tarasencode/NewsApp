//
//  ChannelsTableViewController.swift
//  NewsApp
//
//  Created by oleG on 22/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import UIKit

class ChannelsTableViewController: UITableViewController {
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var noChannelsLabel: UILabel!
    
    var favorites = [Channel]()
    var channels = [Channel]()
    
    var page: Page = .unset
    enum Page {
        case channels
        case favorites
        case unset
    }
    var showNewsItem: UIBarButtonItem!
    var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNewsItem = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = nil

        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.startAnimating()
        if let savedChannels = Channel.loadChannels() {
            channels = savedChannels
            loadFavorites()
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            fetchChannels { (serverChannels) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    guard let serverChannels = serverChannels else {
                        self.loadFavorites()
                        self.showError("Can't load channels. Please check your internet connection.")
                        return
                    }
                    self.channels = serverChannels
                    Channel.saveChannels(self.channels)
                    self.loadFavorites()
                }
            }
        }        
    }
    
    func fetchChannels(completion: @escaping ([Channel]?) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let endpointURL = URL(string: "https://newsapi.org/v2/sources")!
        let query = ["":""]
        let url = endpointURL.withQueriesAndAPIkey(query)!
        let task = URLSession.shared.dataTask(with: url) { (data,
            response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data,
                let answer = try?
                    jsonDecoder.decode(ChanelServerAnswer.self, from: data) {
                completion(answer.sources)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func loadFavorites(){
        favorites = channels.filter {$0.isFavorite == true}
        activityIndicator.stopAnimating()
        if favorites.count > 0,
                firstAppear {
            tabBarController!.selectedIndex = 1
        }
        firstAppear = false
        updateState()
    }
    
    func updateState() {
        switch tabBarController!.selectedIndex {
        case 0:
            navigationItem.title = "Channels"
            page = .channels
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            noChannelsLabel.text = (channels.count < 1) ? "Channels list is empty" : nil
        default:
            navigationItem.title = "Favorites"
            page = .favorites
            navigationItem.leftBarButtonItem = self.editButtonItem
            navigationItem.rightBarButtonItem = showNewsItem
            navigationItem.rightBarButtonItem?.isEnabled = !favorites.isEmpty
            noChannelsLabel.text = (favorites.count < 1) ? "Favorites is empty" : nil
        }
        tableView.reloadData()
    }
    
    func showError(_ errorMessage: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (page == .channels) ? channels.count : favorites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell") as! ChannelCell
        cell.delegate = self
        
        let channel = (page == .channels) ? channels[indexPath.row] : favorites[indexPath.row]
        cell.favoriteButton.isHidden = (page == .channels) ? false : true                
        cell.id = channel.id
        cell.nameLabel.text = channel.name
        cell.descriptionLabel.text = channel.description
        cell.favoriteButton.isSelected = channel.isFavorite ?? false
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (page == .favorites) ? true : false
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let channelIndex = channels.firstIndex(where: {$0.id == favorites[indexPath.row].id})!
            channels[channelIndex].isFavorite = false
            Channel.saveChannels(channels)
            favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            updateState()
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowNews" {
            segue.destination.navigationItem.title = "News"
            segue.destination.navigationItem.largeTitleDisplayMode = .never
            let newsTableViewController = segue.destination as! NewsTableViewController
            newsTableViewController.fromSegue = true
            var sources = [String]()
            for favorite in favorites {
                sources.append(favorite.id)
            }
            newsTableViewController.sources = sources.joined(separator: ",")
        }
    }
}

//MARK: - Extensions

extension ChannelsTableViewController: ChannelCellDelegate {
    func starPressed(sender: ChannelCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            var channel = channels[indexPath.row]
            let toggle = channel.isFavorite ?? false
            channel.isFavorite = !toggle
            channels[indexPath.row] = channel
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            Channel.saveChannels(channels)
        }
    }
}
