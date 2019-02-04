//
//  VenueFilterTableViewCellCheckbox.swift
//  boston-shows
//
//  Created by William Hughes on 3/31/18.
//  Copyright © 2018 William Hughes. All rights reserved.
//

import UIKit
import BEMCheckBox

class VenueFilterTableViewCellCheckbox: BEMCheckBox {
    
    var venueText: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

protocol VenueFilterTableViewCellCheckboxDelegate: BEMCheckBoxDelegate {
    func didTap(_ checkBox: VenueFilterTableViewCellCheckbox)
}

