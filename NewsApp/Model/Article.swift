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
    let content: String?
    var image: Data?
}
