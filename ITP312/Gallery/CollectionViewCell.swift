//
//  CollectionViewCell.swift
//  ITP312
//
//  Created by tyr on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func displayContent(image: UIImage, price: String) {
        imageView.image = image
        nameLabel.text = "$" + price
    }
}
