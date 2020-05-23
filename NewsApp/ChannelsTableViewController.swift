//
//  ViewController.swift
//  NewsApp
//
//  Created by oleG on 21/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import UIKit

class ChannelsTableViewController: UITableViewController, ChannelCellDelegate {
    
    var channels = [Channel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedChannels = Channel.loadChannels() {
            channels = savedChannels
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            fetchChannels { (serverChannels) in
                DispatchQueue.main.async {
                    guard let serverChannels = serverChannels else {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        return
                    }
                    self.channels = serverChannels
                    self.tableView.reloadData()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Channel.saveChannels(channels)
        print("Saving \(channels.count) channels") //MARK: - TEMP!
    }
    
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
                    jsonDecoder.decode(ServerAnswer.self, from: data) {
                completion(answer.sources)
            } else {
                print("Either no data was returned, or data was notserialized.")
                    completion(nil)
            }
        }
        task.resume()
    }
    
    //MARK: - Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell") as? ChannelCell else {
            fatalError("Could not dequeue a cell")
        }
        
        let channel = channels[indexPath.row]
        cell.nameLabel.text = channel.name
        cell.descriptionLabel.text = channel.description
        cell.isFavoriteButton.isSelected = channel.isFavorite ?? false
        
        cell.delegate = self
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 140
//    }
}

