//
//  JugglerProfileHeaderCell.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 15/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

protocol JugglerProfileHeaderCellDelegate {
    func toolBarValueChanged(fromButton button: Int)
}

class JugglerProfileHeaderCell: UICollectionViewCell {
    
    //MARK: Stored properties
    var delegate: JugglerProfileHeaderCellDelegate?
    
    var juggler: Juggler? {
        didSet {
            guard let juggler = juggler else {
                print("JugglerProfileHeaderCellDelegate/Juggler?: Value is nil")
                return
            }
            profileImageView.loadImage(from: juggler.profileImageURLString)
            fullNameLabel.text = juggler.fullName
        }
    }
    
    var rating: Double? {
        didSet {
            guard let rating = rating else { print("JugglerProfileHeader/rating?: No rating"); return}
            modifyStars(withRating: rating)
        }
    }
    
    func modifyStars(withRating rating: Double) {
        let stars = UIView.ratingImage(fromRating: rating)
        starView.image = stars
    }
    
    let starView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "zeroStarRating").withRenderingMode(.alwaysOriginal)
        
        return imageView
    }()
    
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
    
    lazy var acceptedButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.mainBlue()
        button.setTitle("Accepted", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleAcceptedButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleAcceptedButton() {
        toolBarChanged(fromButton: 0)
    }
    
    lazy var completedButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.4)
        button.setTitle("Completed", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleCompletedButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleCompletedButton() {
        toolBarChanged(fromButton: 1)
    }
    
    lazy var reviewsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.4)
        button.setTitle("Reviews", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleReviewsButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleReviewsButton() {
        toolBarChanged(fromButton: 2)
    }
    
    fileprivate func toolBarChanged(fromButton button: Int) {
        delegate?.toolBarValueChanged(fromButton: button)
        
        acceptedButton.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.4)
        completedButton.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.4)
        reviewsButton.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.4)
        
        // button values
        // 0 == acceptedButton
        // 1 == completedButton
        // 2 == reviewsButton
        
        if button == 0 {
            acceptedButton.backgroundColor = UIColor.mainBlue()
        } else if button == 1 {
            completedButton.backgroundColor = UIColor.mainBlue()
        } else if button == 2 {
            reviewsButton.backgroundColor = UIColor.mainBlue()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStarStack()
    }
    
    fileprivate func setupStarStack() {
        addSubview(starView)
        starView.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 190, height: 45)
        starView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        addSubview(profileImageView)
        profileImageView.anchor(top: starView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 100/2
        
        addSubview(fullNameLabel)
        fullNameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: -20, width: nil, height: 50)
        
        setupBottomToolBar()
    }
    
    // Setup tool bar for changing between user reviews and tasks
    fileprivate func setupBottomToolBar() {
        let topDivider = UIView()
        topDivider.backgroundColor = UIColor.mainBlue()
        
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = UIColor.mainBlue()
        
        let stackView = UIStackView(arrangedSubviews: [acceptedButton, completedButton, reviewsButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDivider)
        addSubview(bottomDivider)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 35)
        
        topDivider.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
        
        bottomDivider.anchor(top: nil, left: leftAnchor, bottom: stackView.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
