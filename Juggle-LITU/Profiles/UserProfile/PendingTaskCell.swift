//
//  PendingTaskCell.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 15/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit

class PendingTaskCell: UICollectionViewCell {
    
    //MARK: Stored properties
    
    var task: Task? {
        didSet {
            guard let task = task else { return }
            
            self.titleLabel.text = task.title
            self.specifyBudgetLabelText(task.budget)
            self.timeAgoLabel.text = task.creationDate.timeAgoDisplay()
            
            if task.isOnline {
                self.specifyLocationLabelText("Online/Phone")
            } else {
                if let location = task.stringLocation {
                    self.specifyLocationLabelText(location)
                } else {
                    self.specifyLocationLabelText("Invalid Location")
                }
            }
        }
    }
    
    var user: User? {
        didSet {
            guard let user = user else {
                return
            }
            
            firstNameLabel.text = user.firstName
        }
    }
    
    let firstNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .darkText
        label.numberOfLines = 0
        
        return label
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor.mainBlue()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    let budgetLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        
        return label
    }()
    
    fileprivate func specifyBudgetLabelText(_ budget: Int) {
        let attributedText = NSMutableAttributedString(string: "Your Budget (Euros): ", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : UIColor.gray])
        attributedText.append(NSAttributedString(string: "\(budget)", attributes: [.font : UIFont.boldSystemFont(ofSize: 16), .foregroundColor : UIColor.mainBlue()]))
        
        budgetLabel.attributedText = attributedText
    }
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        
        return label
    }()
    
    fileprivate func specifyLocationLabelText(_ location: String) {
        let attributedText = NSMutableAttributedString(string: "Location: ", attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : UIColor.gray])
        attributedText.append(NSAttributedString(string: location, attributes: [.font : UIFont.systemFont(ofSize: 14), .foregroundColor : UIColor.gray]))
        
        locationLabel.attributedText = attributedText
    }
    
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
    
    fileprivate func setupViews() {
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 60 / 2
        
        addSubview(firstNameLabel)
        firstNameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: profileImageView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: nil, height: nil)
        firstNameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        addSubview(titleLabel)
        titleLabel.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 25)
        
        addSubview(budgetLabel)
        budgetLabel.anchor(top: titleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 20)
        
        addSubview(locationLabel)
        locationLabel.anchor(top: budgetLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 20)
        
        addSubview(timeAgoLabel)
        timeAgoLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: self.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: -8, paddingRight: -8, width: nil, height: nil)
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = UIColor.mainBlue()
        
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: nil, height: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
