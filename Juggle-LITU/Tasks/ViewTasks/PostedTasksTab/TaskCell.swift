//
//  TaskCell.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 2019-10-19.
//  Copyright © 2019 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class TaskCell: UICollectionViewCell {
    
    //MARK: Stored properties
    func fetchUser(fromUId uid: String) {
        Database.fetchUserFromUserID(userID: uid) { (userr) in
            guard let user = userr else {
                DispatchQueue.main.async {
                    self.profileImageView.image = #imageLiteral(resourceName: "default_profile_image")
                }
                return
            }
            self.userFirstNameLabel.text = user.firstName
            DispatchQueue.main.async {
                self.profileImageView.loadImage(from: user.profileImageURLString)
            }
        }
    }
    
    var task: Task? {
        didSet {
            guard let task = task else { print("No task for cell"); return }
            fetchUser(fromUId: task.userId)
            self.titleLabel.text = task.title
            
            let attributedText = NSMutableAttributedString(string: "EARN", attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor : UIColor.mainAmarillo()])
            attributedText.append(NSAttributedString(string: "\n\n", attributes: [.font : UIFont.systemFont(ofSize: 6)]))
            attributedText.append(NSAttributedString(string: "€", attributes: [.font : UIFont.boldSystemFont(ofSize: 22), .foregroundColor : UIColor.mainAmarillo()]))
            attributedText.append(NSAttributedString(string: String(task.budget), attributes: [.font : UIFont.boldSystemFont(ofSize: 22), .foregroundColor : UIColor.mainAmarillo()]))
            
            self.budgetLabel.attributedText = attributedText
            
            if task.isOnline {
                self.locationLabel.text = "Online/Phone"
            } else {
                self.locationLabel.text = task.stringLocation
            }
            self.timeAgoLabel.text = task.creationDate.timeAgoDisplay()
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    let userFirstNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .darkText
        label.numberOfLines = 0
        
        return label
    }()
    
    let budgetLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.mainBlue()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        
        return label
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
        
        addSubview(userFirstNameLabel)
        userFirstNameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: nil, height: nil)
        userFirstNameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        addSubview(budgetLabel)
        budgetLabel.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: -8, paddingRight: -8, width: 80, height: nil)
        
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: profileImageView.centerYAnchor, right: budgetLabel.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: nil)
        
        addSubview(locationLabel)
        locationLabel.anchor(top: titleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: budgetLabel.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: nil)
        
        addSubview(timeAgoLabel)
        timeAgoLabel.anchor(top: locationLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: budgetLabel.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: -8, paddingRight: -8, width: nil, height: nil)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor.mainBlue()
        addSubview(seperatorView)
        seperatorView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
}
