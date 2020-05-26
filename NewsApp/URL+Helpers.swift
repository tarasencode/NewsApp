//
//  URL+Helpers.swift
//  NewsApp
//
//  Created by oleG on 22/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import Foundation

extension URL {
    func withQueriesAndAPIkey(_ queries: [String: String]) -> URL? {
        var queries = queries
        queries["apiKey"] = "ce1bd0fac4c8486393a3708cceaeb813"
        var components = URLComponents(url: self,
                                       resolvingAgainstBaseURL: true)
        components?.queryItems = queries.map
            { URLQueryItem(name: $0.0, value: $0.1) }
        return components?.url
    }
}
