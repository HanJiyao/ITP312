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
            let ref = Database.database().reference().child("users")
            ref.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    if let profileURL = dictionary["profileURL"] as? String {
                        self.profileImage.loadImageCache(urlString: profileURL)
                    }
                }
            })
        }
        self.timeLabel.text = guide?.date
        self.detailTextLabel?.text = guide?.service
        self.descLabel.text = guide?.desc
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect.init(x: 120, y: textLabel!.frame.origin.y - 9, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect.init(x: 120, y: detailTextLabel!.frame.origin.y - 7, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImage:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "no-image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
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
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
