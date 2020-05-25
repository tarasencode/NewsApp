//
//  NewsTableViewController.swift
//  NewsApp
//
//  Created by oleG on 23/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import UIKit
import SafariServices

class NewsTableViewController: UITableViewController, UISearchResultsUpdating {
        
    var resultSearchController = UISearchController()
    
    var news = [Article]()
    
    var fromSegue: Bool = false
    var sources: String = ""
   
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        guard let searchString = searchController.searchBar.text,
            searchString != "" else {return}
        
        let query: [String: String] = [
            "apiKey": "ce1bd0fac4c8486393a3708cceaeb813",
            "q": searchString
        ]
        self.perform(#selector(self.sendRequest), with: query, afterDelay: 1.5)
    }
    
    @objc func sendRequest(_ query: [String: String]) {
        print(query)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        fetchNews(query: query, completion: { (serverNews) in
            DispatchQueue.main.async {
                guard let serverNews = serverNews else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    return
                }
                self.news.append(contentsOf: serverNews)
                self.downloadImages()
                self.tableView.reloadData()
            }
        })
    }
    
    func fetchNews(query: [String: String],  completion: @escaping ([Article]?) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let baseURL = URL(string: "https://newsapi.org/v2/everything")!
        
        
        let url = baseURL.withQueries(query)!
        let task = URLSession.shared.dataTask(with: url) { (data,
            response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data,
                let answer = try?
                    jsonDecoder.decode(ArticleServerAnswer.self, from: data) {
                completion(answer.articles)
            } else {
                print("Either no data was returned, or data was notserialized.")
                completion(nil)
            }
        }
        task.resume()
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
                    self.news[index].image = data
                    DispatchQueue.main.async {
                        guard self.tableView.numberOfRows(inSection: 0) != 0 else {return}
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
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        
        print(fromSegue)
        guard fromSegue else {return}
        
        let query: [String: String] = [
            "apiKey": "ce1bd0fac4c8486393a3708cceaeb813",
            "sources": sources
        ]
        sendRequest(query)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fromSegue = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 240

        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.obscuresBackgroundDuringPresentation = false
            controller.searchBar.placeholder = "Type anything"
            //controller.dimsBackgroundDuringPresentation = false
            //controller.searchBar.sizeToFit()
            //controller.hidesNavigationBarDuringPresentation = false
            //tableView.tableHeaderView = controller.searchBar
            navigationItem.searchController = controller
            definesPresentationContext = true
            
            return controller
        })()
        
        tableView.reloadData()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        

            return news.count

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell

        let article = news[indexPath.row]
        cell.id = indexPath.row
        cell.articleTitle.text = article.title?.removeHTMLTag()
        cell.articleDescription.text = article.description?.removeHTMLTag()
        if article.image != nil {
            cell.articleImage.image = UIImage(data: article.image!)
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: news[indexPath.row].url!)!
        let config = SFSafariViewController.Configuration.init()
        config.entersReaderIfAvailable = true
        let safariVC = SFSafariViewController(url: url, configuration: config)
        present(safariVC, animated: true, completion: nil)
        
    }

}

extension NewsTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.row > 13 {
                
            }
        }
        print("prefetch \(indexPaths )\n")
        
    }
}

