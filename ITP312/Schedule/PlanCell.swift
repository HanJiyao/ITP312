//
//  PlanCell.swift
//  SDDP_Project_JR
//
//  Created by Jia Rong on 2/2/20.
//  Copyright © 2020 Jia Rong. All rights reserved.
//

import UIKit

class PlanCell: UITableViewCell {

    
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var destinationNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
