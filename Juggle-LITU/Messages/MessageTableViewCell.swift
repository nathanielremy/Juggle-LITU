//
//  MessageTableViewCell.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 14/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

class MessageTableViewCell: UITableViewCell {
    
    //MARK: Stored properties
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    @objc fileprivate func handleProfileImageView() {
        print("Handle profile image view")
    }
    
    let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.mainBlue()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        label.text = "This is a task title for some task shit"
        
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        
        label.text = "Nathaniel Remy Duuude"
        
        return label
    }()
    
    let messageTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        
        label.text = "HEllO there mister I would like to thank you for everything that you have done. Great work."
        
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        
        label.text = "3 weeks ago"
        
        return label
    }()
    
    let taskStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "Status: ", attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor : UIColor.gray])
        attributedText.append(NSAttributedString(string: "Completed", attributes: [.font : UIFont.boldSystemFont(ofSize: 12), .foregroundColor : UIColor.mainBlue()]))
        
        label.attributedText = attributedText
        
        return label
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Accept Juggler", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handleAcceptedButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleAcceptedButton() {
        print("handleAcceptedButton")
    }
    
    lazy var viewTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Task", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainBlue()
        button.addTarget(self, action: #selector(handleViewTaskButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleViewTaskButton() {
        print("handleViewTaskButton")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        addSubview(profileImageView)
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50/2
        
        //Add button over profileImageView to view user's profile
        let button = UIButton()
        button.backgroundColor = nil
        addSubview(button)
        button.anchor(top: profileImageView.topAnchor, left: profileImageView.leftAnchor, bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        button.layer.cornerRadius = 50/2
        button.addTarget(self, action: #selector(handleProfileImageView), for: .touchUpInside)
        
        // Setup buttons on right.
        let stackView = UIStackView(arrangedSubviews: [taskStatusLabel, acceptButton, viewTaskButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        acceptButton.layer.cornerRadius = 13
        viewTaskButton.layer.cornerRadius = 13
        
        addSubview(stackView)
        stackView.anchor(top: self.topAnchor, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: -4, paddingRight: -8, width: 112, height: nil)
        
        addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: stackView.leftAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 22)
        
        addSubview(nameLabel)
        nameLabel.anchor(top: taskTitleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: stackView.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 20)
        
        addSubview(messageTextLabel)
        messageTextLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: stackView.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 20)
        
        addSubview(timeLabel)
        timeLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: self.bottomAnchor, right: stackView.leftAnchor, paddingTop: 5, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 20)
        
//        setupBottomToolBar()
    }
    
    fileprivate func setupBottomToolBar() {
        let topSeperatorView = UIView()
        topSeperatorView.backgroundColor = UIColor.mainBlue()
        addSubview(topSeperatorView)
        topSeperatorView.anchor(top: timeLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
        
        addSubview(taskStatusLabel)
        taskStatusLabel.anchor(top: topSeperatorView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 4, paddingLeft: 30, paddingBottom: 0, paddingRight: -8, width: nil, height: 20)
        
        let stackView = UIStackView(arrangedSubviews: [acceptButton, viewTaskButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        
        acceptButton.layer.cornerRadius = 13
        viewTaskButton.layer.cornerRadius = 13
        
        addSubview(stackView)
        stackView.anchor(top: taskStatusLabel.bottomAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: -6, paddingRight: -30, width: nil, height: 25)
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = UIColor.mainBlue()
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
