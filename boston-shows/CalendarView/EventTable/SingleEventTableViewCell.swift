//
//  SingleEventTableViewCell.swift
//  boston-shows
//
//  Created by William Hughes on 3/29/18.
//  Copyright © 2018 William Hughes. All rights reserved.
//

import UIKit

class SingleEventTableViewCell: UITableViewCell {
    
    // MARK: Properties
    var eventObject: SingleEvent!

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var favButton: EventCellFavButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
