//
//  FavsTableViewCell.swift
//  boston-shows
//
//  Created by William Hughes on 4/7/18.
//  Copyright © 2018 William Hughes. All rights reserved.
//

import UIKit

class FavsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var bandsLabel: UILabel!
    @IBOutlet weak var timeVenueLabel: UILabel!
    
    var eventObject: SingleEvent!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
