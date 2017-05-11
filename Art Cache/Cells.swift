//
//  Cells.swift
//  Art Cache
//
//  Created by Rey Cerio on 2017-04-06.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
    }
}

class ArtTrackerCollectionViewCell: BaseCell {
        
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = #imageLiteral(resourceName: "taka")
        image.layer.cornerRadius = 10
        image.layer.masksToBounds = true
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Art"
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addSubview(titleLabel)
        
        addConstraintsWithFormat(format: "H:|-2-[v0(60)]-2-[v1]-2-|", views: imageView, titleLabel)
        addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: titleLabel)
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        backgroundColor = .white
        titleLabel.text = nil
    }
}

class PendingCell: BaseCell {
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 10
        image.layer.masksToBounds = true
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("accept", for: .normal)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(acceptButton)
        
        addConstraintsWithFormat(format: "H:|-2-[v0(60)]-2-[v1]-2-[v2(50)]-2-|", views: imageView, titleLabel, acceptButton)
        addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: titleLabel)
        addConstraintsWithFormat(format: "V:|[v0]|", views: acceptButton)
        
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        titleLabel.text = nil
    }
}

class CommentCell: BaseCell {
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    let userLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(textView)
        addSubview(userLabel)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: textView)
        addConstraintsWithFormat(format: "H:|-6-[v0]|", views: userLabel)
        addConstraintsWithFormat(format: "V:|[v0(35)][v1]", views: textView, userLabel)
    }
    
    override func prepareForReuse() {
        textView.text = nil
        userLabel.text = nil
    }
}

