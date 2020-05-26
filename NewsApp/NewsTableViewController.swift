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
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var resultSearchController = UISearchController()
    
    var news = [Article]()
    
    var fromSegue: Bool = false
    var sources: String = ""
    var loadInProgress = false
    var serverNewsCount = 0
   
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        guard let searchString = searchController.searchBar.text,
            searchString != "" else {return}
        
        let query: [String: String] = [
            "q": searchString
        ]
        self.perform(#selector(self.sendRequest), with: query, afterDelay: 1.5)
    }
    
    @objc func sendRequest(_ query: [String: String]) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        fetchNews(query: query, completion: { (serverNews) in
            DispatchQueue.main.async {
                guard let serverNews = serverNews else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    return
                }
                self.news = serverNews
                self.downloadImages()
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        })
    }
    
    func fetchNews(query: [String: String],  completion: @escaping ([Article]?) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let endpointURL = URL(string: "https://newsapi.org/v2/everything")!
        let url = endpointURL.withQueriesAndAPIkey(query)!
        print("Request:\n\(url)")
        let task = URLSession.shared.dataTask(with: url) { (data,
            response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data,
                let answer = try? jsonDecoder.decode(ArticleServerAnswer.self, from: data) {
                    print("\nStatus: \(answer.status) Total results: \(answer.totalResults)")
                    guard answer.totalResults > 0 else { // 0 articles on channel
                    print("Warning: No articles on this channel")
                    completion(nil)
                    return
                }
                completion(answer.articles)
                self.serverNewsCount = answer.totalResults
            } else {
                print("Request:\n\(url)\nResponse:\n\(String(describing: response))\nError:\n\(String(describing: error))")
                completion(nil)
            }
        }
        task.resume()
    }
    
    
    func requestNewPage(indexPaths: [IndexPath]) {
        guard loadInProgress == false,
            news.count < 100, // FIXME: limit or free API subscription
            serverNewsCount != news.count else {return}
        if indexPaths.first!.row >= news.count - 1 {
            loadInProgress = true
            activityIndicator.startAnimating()
            
            let currentPage = (news.count - 1) / 20 + 1
            
            if !fromSegue { // From Search tab
                guard let searchString = resultSearchController.searchBar.text,
                    searchString != "" else {
                        activityIndicator.stopAnimating()
                        return
                }
                
                let query: [String: String] = [
                    "q": searchString,
                    "page" : String(currentPage + 1)
                ]
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                fetchNews(query: query, completion: { (serverNews) in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        guard let serverNews = serverNews else {return}
                        
                        self.news.append(contentsOf: serverNews)
                        self.downloadImages()
                        self.appendNewRows()
                        self.loadInProgress = false
                        self.activityIndicator.stopAnimating()
                    }
                })
            } else { // From Show News Segue
                let query: [String: String] = [
                    "sources": sources,
                    "page" : String(currentPage + 1)
                ]
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                fetchNews(query: query, completion: { (serverNews) in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        guard let serverNews = serverNews else {return}
                        
                        self.news.append(contentsOf: serverNews)
                        self.downloadImages()
                        self.appendNewRows()
                        self.loadInProgress = false
                        self.activityIndicator.stopAnimating()
                    }
                })
            }
        }
    }
    
    func appendNewRows() {
        let lastRowInTable = tableView.numberOfRows(inSection: 0) - 1
        var newIndexPaths = [IndexPath]()
        for index in lastRowInTable + 1...news.count - 1 {
            newIndexPaths.append(IndexPath(row: index, section: 0))
        }
        UIView.setAnimationsEnabled(false)
        tableView.insertRows(at: newIndexPaths, with: .none)
        UIView.setAnimationsEnabled(true)

    }
    
    func fetchImage(from urlString: String, completionHandler: @escaping (_ data: Data?) -> ()) {
        if let url = URL(string: urlString) {            
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in completionHandler(data) }
            dataTask.resume()
        }
    }
    
    func downloadImages() {
        for index in news.indices {
            guard news[index].urlToImage != nil,
                news[index].urlToImage != "null",
                news[index].urlToImage != "",
                    news[index].image == nil else {continue}
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            fetchImage(from: news[index].urlToImage!, completionHandler: { (imageData) in
                if let data = imageData {
                    self.news[index].image = data
                    DispatchQueue.main.async {
                        guard self.tableView.numberOfRows(inSection: 0) != 0,
                                index < 20 else {return} // reload rows from the first page
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                } else {
                    print("Error fetching image: \n\(self.news[index].urlToImage!)")
                }
                DispatchQueue.main.async {
                    if index == self.news.indices.last {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            })
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if fromSegue {
            let query: [String: String] = [
                "sources": sources
            ]
            sendRequest(query)
        } else {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if fromSegue {
            
        } else {
            
            resultSearchController = ({
                let controller = UISearchController(searchResultsController: nil)
                controller.searchResultsUpdater = self
                controller.obscuresBackgroundDuringPresentation = false
                controller.searchBar.placeholder = "Type anything"
                //controller.dimsBackgroundDuringPresentation = false
                //controller.searchBar.sizeToFit()
                //controller.hidesNavigationBarDuringPresentation = false
                navigationItem.searchController = controller
                definesPresentationContext = true
                
                return controller
            })()
        }
        tableView.prefetchDataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if fromSegue {
            
        } else {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fromSegue = false
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
        } else {
            cell.articleImage.image = nil
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
        requestNewPage(indexPaths: indexPaths)
    }
}

