//
//  String+Helpers.swift
//  NewsApp
//
//  Created by oleG on 24/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import Foundation

extension String {
    func removeHTMLTag() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
    }
}
