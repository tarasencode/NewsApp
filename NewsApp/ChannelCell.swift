//
//  ChannelCell.swift
//  NewsApp
//
//  Created by oleG on 22/05/2020.
//  Copyright © 2020 Oleg Tarasenko. All rights reserved.
//

import UIKit

protocol ChannelCellDelegate: class {
    func starPressed(sender: ChannelCell)
}

class ChannelCell: UITableViewCell {
    @IBOutlet var isFavoriteButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        delegate?.starPressed(sender: self)
    }
    
    weak var delegate: ChannelCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
