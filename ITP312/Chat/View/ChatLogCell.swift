//
//  ChatLogCell.swift
//  ITP312
//
//  Created by ITP312 on 28/1/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase

class ChatLogCell: UITableViewCell {
    
    static let blueColor = UIColor.init(red: 3/255, green: 169/255, blue: 244/255, alpha: 1)
    
    let textView: UITextView = {
        let view = UITextView()
        view.font = UIFont.systemFont(ofSize: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.textColor = UIColor.white
        view.isEditable = false
        return view
    }()
    
    let bubbleView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "no-image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
//    let messageImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.layer.cornerRadius = 16
//        imageView.clipsToBounds = true
//        imageView.contentMode = UIView.ContentMode.scaleAspectFit
//        return imageView
//    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImage)
        
        // bubbleView.addSubview(messageImageView)

        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 8)
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)

        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleViewRightAnchor?.isActive = false
        bubbleViewLeftAnchor?.isActive = true
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
//        messageImageView.layer.borderColor = UIColor.init(red: 0, green: 0 , blue: 0, alpha: 1).cgColor
//        messageImageView.layer.borderWidth = 2
        
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: 8).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 36).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
//        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor)
//        messageImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor)
//        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor)
//        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
