//
//  VenueFilterTableViewCell.swift
//  boston-shows
//
//  Created by William Hughes on 3/31/18.
//  Copyright © 2018 William Hughes. All rights reserved.
//

import UIKit
import BEMCheckBox

class VenueFilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellCheckBox: VenueFilterTableViewCellCheckbox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellCheckBox.venueText = self.textLabel?.text
        cellCheckBox.onAnimationType = BEMAnimationType.bounce
        cellCheckBox.offAnimationType = BEMAnimationType.bounce
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setVenue(venue: String) {
        self.textLabel?.text = venue
        self.cellCheckBox.venueText = venue
    }

}
