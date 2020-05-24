//
//  ChannelsTableViewController.swift
//  NewsApp
//
//  Created by oleG on 22/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import UIKit

class ChannelsTableViewController: UITableViewController, ChannelCellDelegate {
    
    var favorites = [Channel]()
    var channels = [Channel]()
    var page: String?
    
    var showNewsItem: UIBarButtonItem!
    
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
    
    func fetchChannels(completion: @escaping ([Channel]?) -> Void)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let baseURL = URL(string: "https://newsapi.org/v2/sources")!
        
        let query: [String: String] = [
            "apiKey": "ce1bd0fac4c8486393a3708cceaeb813",
            "country": "gb"
        ]
        
        let url = baseURL.withQueries(query)!
        let task = URLSession.shared.dataTask(with: url) { (data,
            response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data,
                //                {
                //                let dataAsString = String(data: data, encoding: .utf8)
                //                print(dataAsString!)
                //            }
                let answer = try?
                    jsonDecoder.decode(ChanelServerAnswer.self, from: data) {
                completion(answer.sources)
            } else {
                print("Either no data was returned, or data was notserialized.")
                completion(nil)
            }
        }
        task.resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let tabIndex = tabBarController?.selectedIndex,
                tabIndex == 0 {
            showChannels()
            channels = Channel.loadChannels()!
            page = "channels"
        } else {
            showFavorites()
            channels = Channel.loadChannels()!
            favorites = Channel.loadChannels()!.filter {$0.isFavorite == true}
            page = "favorites"
            
        }
        tableView.reloadData()
        updateNavigationButtonState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNewsItem = navigationItem.rightBarButtonItem
        
//        if let savedChannels = Channel.loadChannels() {
//            channels = savedChannels
//        } else {
//            UIApplication.shared.isNetworkActivityIndicatorVisible = true
//            fetchChannels { (serverChannels) in
//                DispatchQueue.main.async {
//                    guard let serverChannels = serverChannels else {
//                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                        return
//                    }
//                    self.channels = serverChannels
//                    //                    self.tableView.reloadData()
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                }
//            }
//        }
        
        
        //self.tabBarController?.selectedIndex = 1
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    func showChannels() {
        navigationItem.title = "Channels"
//        navigationItem.leftBarButtonItem = nil
//        navigationItem.rightBarButtonItem = nil
    }
    
    func showFavorites() {
        navigationItem.title = "Favorites"
//        navigationItem.rightBarButtonItem = showNewsItem
//        navigationItem.rightBarButtonItem?.isEnabled = !favorites.isEmpty

    }
    

    
    func updateNavigationButtonState() {
        navigationItem.rightBarButtonItem = (page == "channels") ? nil : showNewsItem
        navigationItem.rightBarButtonItem?.isEnabled = !favorites.isEmpty
        navigationItem.leftBarButtonItem = (favorites.isEmpty) ? nil:self.editButtonItem
        
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (page == "channels") ? channels.count : favorites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell") as? ChannelCell else {
            fatalError("Could not dequeue a cell")
        }
        

        cell.isFavoriteButton.isHidden = (page == "channels") ? false : true

        
        let channel = (page == "channels") ? channels[indexPath.row] : favorites[indexPath.row]
        
        cell.id = channel.id
        cell.nameLabel.text = channel.name
        cell.descriptionLabel.text = channel.description
        cell.isFavoriteButton.isSelected = channel.isFavorite ?? false
        
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true
    }
 
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let channelIndex = channels.firstIndex(where: {$0.id == favorites[indexPath.row].id})!
            channels[channelIndex].isFavorite = false
            Channel.saveChannels(channels)
            favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            

            updateNavigationButtonState()
        }
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}