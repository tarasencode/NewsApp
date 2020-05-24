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
        
        let tb = self.tabBarController as! TabBarController
        channels = tb.channels
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
            channel.isFavorite = toggle
            channels[indexPath.row] = channel
            tableView.reloadRows(at: [indexPath], with: .automatic)
            Channel.saveChannels(channels)
        }
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

