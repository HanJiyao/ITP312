//
//  PlanLocationCell.swift
//  ITP312
//
//  Created by Jia Rong on 10/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

class PlanLocationCell: UITableViewCell {

    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationSubtitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
