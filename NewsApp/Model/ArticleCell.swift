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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
