//
//  ArticleCell.swift
//  NewsApp
//
//  Created by oleG on 23/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import UIKit


class ArticleCell: UITableViewCell {
    @IBOutlet var articleImage: UIImageView!
    @IBOutlet var articleTitle: UILabel!
    @IBOutlet var articleDescription: UILabel!
    
    var id: Int!
      
}
