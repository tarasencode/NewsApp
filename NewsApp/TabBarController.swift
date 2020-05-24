//
//  TabBarController.swift
//  NewsApp
//
//  Created by oleG on 23/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    var channels = [Channel]()

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
//                    self.tableView.reloadData()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
    }

}
