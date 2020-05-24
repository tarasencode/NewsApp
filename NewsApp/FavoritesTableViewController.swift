//
//  FavoritesTableViewController.swift
//  NewsApp
//
//  Created by oleG on 22/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {
    
    var favorites = [Channel]()
    var showNewsItem: UIBarButtonItem!
    

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(tabBarController?.selectedIndex)

        if let tabIndex = tabBarController?.selectedIndex,
                tabIndex == 0 {
            showChannels()
        } else {
            showFavorites()
        }
        
        if let savedChannels = Channel.loadChannels() {
            favorites = savedChannels.filter {$0.isFavorite == true}
            tableView.reloadData()
        } else {
            // no channels
        }
        updateNavigationButtonState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNewsItem = navigationItem.rightBarButtonItem
        //self.tabBarController?.selectedIndex = 1
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        
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
        navigationItem.rightBarButtonItem?.isEnabled = !favorites.isEmpty
        navigationItem.leftBarButtonItem = (favorites.isEmpty) ? nil:self.editButtonItem
        
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
        
        let channel = favorites[indexPath.row]
        cell.textLabel?.text = channel.name
        cell.detailTextLabel?.text = channel.description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true
    }
 
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
//            segue.destination.navigationItem.searchController = nil
//            let newsTableViewController = segue.destination as! NewsTableViewController
//            newsTableViewController.tableView.tableHeaderView = nil
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}
