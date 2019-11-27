//
//  UserProfileHeader.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 09/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileHeaderCellDelegate {
    func toolBarValueChanged(fromButton button: Int)
    func handleEditProfileButton()
}

class UserProfileHeader: UICollectionViewCell {
    
    //MARK: Stored properties
    var delegate: UserProfileHeaderCellDelegate?
    var user: User? {
        didSet {
            guard let user = user else {
                print("UserProfileHeader/user?: NO USER...")
                return
            }
            profileImageView.loadImage(from: user.profileImageURLString)
            fullNameLabel.text = user.firstName + " " + user.lastName
        }
    }
    
    let profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.backgroundColor = .lightGray
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.mainBlue().cgColor
        image.layer.borderWidth = 1.5
        
        return image
    }()
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.mainBlue().cgColor
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1.5
        button.addTarget(self, action: #selector(handleEditProfileButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleEditProfileButton() {
        delegate?.handleEditProfileButton()
    }
    
    //MARK: Pending button
    lazy var pendingButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.mainBlue()
        button.setTitle("Pending", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handlePendingButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handlePendingButton() {
        toolBarChanged(fromButton: 0)
    }
    
    //MARK: Accepted button
    lazy var acceptedButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.4)
        button.setTitle("Accepted", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleAcceptedButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleAcceptedButton() {
        toolBarChanged(fromButton: 1)
    }
    
    //MARK: Completed button
    lazy var completedButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.4)
        button.setTitle("Completed", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleCompletedButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleCompletedButton() {
        toolBarChanged(fromButton: 2)
    }
    
    fileprivate func toolBarChanged(fromButton button: Int) {
        delegate?.toolBarValueChanged(fromButton: button)
        
        pendingButton.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.4)
        acceptedButton.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.4)
        completedButton.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.4)
        
        // button values
        // 0 == pendingButton
        // 1 == acceptedButton
        // 2 == completedButton
        
        if button == 0 {
            pendingButton.backgroundColor = UIColor.mainBlue()
        } else if button == 1 {
            acceptedButton.backgroundColor = UIColor.mainBlue()
        } else if button == 2 {
            completedButton.backgroundColor = UIColor.mainBlue()
        }
    }
    
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
        profileImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 100/2
        
        addSubview(fullNameLabel)
        fullNameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        
        addSubview(editProfileButton)
        editProfileButton.anchor(top: fullNameLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 34)
        editProfileButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        setupBottomToolBar()
    }
    
    // Set up tool bar changing between pending, accepted and completed tasks.
    fileprivate func setupBottomToolBar() {
        let topDivider = UIView()
        topDivider.backgroundColor = UIColor.mainBlue()
        
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = UIColor.mainBlue()
        
        let stackView = UIStackView(arrangedSubviews: [pendingButton, acceptedButton, completedButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        addSubview(stackView)
        addSubview(topDivider)
        addSubview(bottomDivider)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 35)
        
        pendingButton.layer.cornerRadius = 35 / 2
        acceptedButton.layer.cornerRadius = 35 / 2
        completedButton.layer.cornerRadius = 35 / 2
    }
}
