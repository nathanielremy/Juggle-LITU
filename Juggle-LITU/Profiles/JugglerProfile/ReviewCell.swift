//
//  ReviewCell.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 21/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class ReviewCell: UICollectionViewCell {
    
    fileprivate func fetchUserFromUserId(uid: String) {
        Database.fetchUserFromUserID(userID: uid) { (userr) in
            guard let user = userr else {
                DispatchQueue.main.async {
                    self.profileImageView.image = #imageLiteral(resourceName: "default_profile_image")
                }
                return
            }
            self.firstNameLabel.text = user.firstName + " " + user.lastName
            DispatchQueue.main.async {
                self.profileImageView.loadImage(from: user.profileImageURLString)
            }
        }
    }
    
    //MARK: Stored properties
    var review: Review? {
        didSet {
            guard let review = review else { print("No review for cell"); return }
            fetchUserFromUserId(uid: review.userId)
            reviewTextView.text = review.reviewString
            starView.image = UIView.ratingImage(fromRating: Double(review.intRating))
            timeAgoLabel.text = review.creationDate.timeAgoDisplay()
        }
    }
    
    lazy var profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    let firstNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .darkText
        label.numberOfLines = 0
        
        return label
    }()
    
    let starView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "zeroStarRating").withRenderingMode(.alwaysOriginal)
        
        return imageView
    }()
    
    let reviewTextView: UITextView = {
        let tf = UITextView()
        tf.isUserInteractionEnabled = false
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .darkText
        tf.backgroundColor = .white
        
        return tf
    }()
    
    let timeAgoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 60 / 2
        
        addSubview(firstNameLabel)
        firstNameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: nil, height: nil)
        firstNameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        addSubview(starView)
        starView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 135, height: 30)
        
        addSubview(timeAgoLabel)
        timeAgoLabel.anchor(top: nil, left: starView.leftAnchor, bottom: self.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 8, width: nil, height: nil)
        
        addSubview(reviewTextView)
        reviewTextView.anchor(top: starView.bottomAnchor, left: profileImageView.rightAnchor, bottom: timeAgoLabel.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: -4, paddingRight: -8, width: nil, height: nil)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor.mainBlue()
        addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
