//
//  MovieTopRatedCell.swift
//  MyMovies
//
//  Created by Un on 10/14/16.
//  Copyright © 2016 Un. All rights reserved.
//

import UIKit

class MovieTopRatedCell: UITableViewCell {

    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
