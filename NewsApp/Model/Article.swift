//
//  Article.swift
//  NewsApp
//
//  Created by oleG on 24/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import Foundation

struct ArticleServerAnswer: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    var image: Data?
    
    public static var serverNewsCount = 0
    
    public static func fetchNews(query: [String: String],  completion: @escaping ([Article]?) -> Void) {
        let endpointURL = URL(string: "https://newsapi.org/v2/everything")!
        let url = endpointURL.withQueriesAndAPIkey(query)!
        print("Request:\n\(url)")
        let task = URLSession.shared.dataTask(with: url) { (data,
            response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data,
                let answer = try? jsonDecoder.decode(ArticleServerAnswer.self, from: data) {
                print("Status: \(answer.status)\nTotal results: \(answer.totalResults)")
                guard answer.totalResults > 0 else { // 0 articles on channel
                    completion(nil)
                    return
                }
                completion(answer.articles)
                serverNewsCount = answer.totalResults
            } else {
                print("Request:\n\(url)\nResponse:\n\(String(describing: response))\nError:\n\(String(describing: error))")
                completion(nil)
            }
        }
        task.resume()
    }
    
    public static func fetchImage(from urlString: String, completionHandler: @escaping (_ data: Data?) -> ()) {
        if let url = URL(string: urlString) {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in completionHandler(data) }
            dataTask.resume()
        }
    }
}
