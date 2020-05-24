//
//  NewsTableViewController.swift
//  NewsApp
//
//  Created by oleG on 23/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    struct ServerAnswer: Codable {
        let status: String
        let totalResults: Int
        let articles: [News]
    }
    
    struct News: Codable {
        let title: String?
        let description: String?
        let url: String?
        let urlToImage: String?
        let content: String?
        var image: Data?
    }
    
    var resultSearchController = UISearchController() //MARK: make better?
    
    var news = [News]()
    
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        guard let searchString = searchController.searchBar.text,
            searchString != "" else {return}
        self.perform(#selector(self.sendSearchRequest), with: searchString, afterDelay: 1.5)
    }
    
    @objc func sendSearchRequest(_ searchString: String) {
        print(searchString)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        fetchNews(searchString: searchString, completion: { (serverNews) in
            DispatchQueue.main.async {
                guard let serverNews = serverNews else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    return
                }
                self.news = serverNews
                self.downloadImages()
                self.tableView.reloadData()
            }
        })
    }
    
    func fetchImage(from urlString: String, completionHandler: @escaping (_ data: Data?) -> ()) {
        let session = URLSession.shared
        let url = URL(string: urlString)
        
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("Error fetching the image!")
                completionHandler(nil)
            } else {
                completionHandler(data)
            }
        }
        
        dataTask.resume()
    }
    
    func downloadImages() {
        for index in news.indices {
            guard news[index].urlToImage != nil else {return}
            fetchImage(from: news[index].urlToImage!, completionHandler: { (imageData) in
                if let data = imageData {
                    NSLog("\(index)")
                    self.news[index].image = data
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        if index == self.news.indices.last {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    }
                } else {
                    print("Error loading image");
                }
            })
        }
    }
    
    func fetchNews(searchString: String, completion: @escaping ([News]?) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let baseURL = URL(string: "https://newsapi.org/v2/everything")!
        
        let query: [String: String] = [
            "apiKey": "ce1bd0fac4c8486393a3708cceaeb813",
            "q": searchString
        ]
        
        let url = baseURL.withQueries(query)!
        let task = URLSession.shared.dataTask(with: url) { (data,
            response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data,
                let answer = try?
                    jsonDecoder.decode(ServerAnswer.self, from: data) {
                completion(answer.articles)
            } else {
                print("Either no data was returned, or data was notserialized.")
                completion(nil)
            }
        }
        task.resume()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 240

        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the table
        tableView.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if  resultSearchController.isActive {
            return news.count
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell

        let article = news[indexPath.row]
        cell.newsTitle.text = article.title?.removeHTMLTag()
        cell.newsDescription.text = article.description?.removeHTMLTag()
        if article.image != nil {
            cell.newsImage.image = UIImage(data: article.image!)
        }
        

        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
