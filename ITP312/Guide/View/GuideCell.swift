//
//  GuideCell.swift
//  ITP312
//
//  Created by ITP312 on 4/2/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class GuideCell: UITableViewCell {
    var guide: Guide? {
        didSet {
            setupNameAndProfile()
        }
    }
    
    func setupNameAndProfile () {
        if let id = guide?.guideID {
            Database.database().reference().child("users").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.descLabel.text = dictionary["name"] as? String
                }
            })
        }
        self.textLabel?.text = guide?.country
        self.profileImage.loadImageCache(urlString: guide!.imgURL!)
        self.timeLabel.text = "\(guide!.fromDate!) to \(guide!.toDate!)"
        self.detailTextLabel?.text = guide?.service
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect.init(x: 120, y: textLabel!.frame.origin.y - 9, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect.init(x: 120, y: detailTextLabel!.frame.origin.y - 7, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImage:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    let descLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImage)
        addSubview(descLabel)
        addSubview(timeLabel)
        
        profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 75).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        descLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 120).isActive = true
        descLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 61).isActive = true
        descLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 180).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
