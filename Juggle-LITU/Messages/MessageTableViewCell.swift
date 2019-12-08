//
//  MessageTableViewCell.swift
//  Juggle-LITU
//
//  Created by Nathaniel Remy on 14/11/2018.
//  Copyright © 2018 Nathaniel Remy. All rights reserved.
//

import UIKit
import Firebase

protocol MessageTableViewCellDelegate {
    func handleProfileImageView(forJuggler juggler: User?)
    func handleViewTaskButton(forTask task: Task?)
    
    // Completion handler's parameter is a status.
    // Check updateAcceptedStatus func for the meaning
    // and values of each status
    func handleAcceptJuggler(forTask task: Task?, juggler: User?, completion: @escaping (Int) -> Void)
}

class MessageTableViewCell: UITableViewCell {
    
    //MARK: Stored properties
    var delegate: MessageTableViewCellDelegate?
    
    var task: Task? {
        didSet {
            guard var task = self.task, let juggler = self.message.1 else {
                self.taskTitleLabel.text = "Task Deleted"
                print("Task property is nil")
                return
            }
            
            self.taskTitleLabel.text = task.title
            if task.mutuallyAcceptedBy == nil {
                task.verifyAndUpdateAcceptance()
            }
            
            if task.status == 2 { // Is task Completed
                self.updateAcceptedStatus(forStatus: 4, userFirstName: juggler.firstName)
                return
            }
            
            if let mutuallyAcceptedBy = task.mutuallyAcceptedBy {
                self.updateAcceptedStatus(forStatus: 3, userFirstName: juggler.firstName)
                
                if juggler.uid == mutuallyAcceptedBy {
                    self.acceptedStatusLabel.text = "\(juggler.firstName) is in progress of completing your \(task.category) task!"
                }
                
                return
            }
            
            // Only move forward if the task is in pending state
            guard task.status == 0 else {
                return
            }
            
            self.updateAcceptedStatus(forStatus: 0, userFirstName: juggler.firstName)
            
            if task.taskAccepters?[juggler.uid] != nil {
                
                self.updateAcceptedStatus(forStatus: 2, userFirstName: juggler.firstName)
                return
                
            } else if task.jugglersAccepted?[juggler.uid] != nil {
                
                self.updateAcceptedStatus(forStatus: 1, userFirstName: juggler.firstName)
                return
            }
        }
    }
    
    fileprivate func updateAcceptedStatus(forStatus status: Int, userFirstName: String) {
        if status == 0 { // Accepted by nobody
            
            self.acceptedStatusLabel.text = "Want to accept \(userFirstName) for your task?"
            self.acceptButton.setTitle("Accept Juggler", for: .normal)
            self.acceptButton.setTitleColor(UIColor.mainBlue(), for: .normal)
            self.acceptButton.isEnabled = true
            
        } else if status == 1 { // Accepted only by current user
            
            self.acceptedStatusLabel.text = "Waiting for \(userFirstName) to accept you back"
            self.acceptButton.setTitle("Accepted", for: .normal)
            self.acceptButton.setTitleColor(UIColor.mainBlue(), for: .normal)
            self.acceptButton.isEnabled = false
            
        } else if status == 2 { // Accepted only by chat partner
            
            self.acceptedStatusLabel.text = "\(userFirstName) has accepted you!"
            self.acceptButton.setTitle("Accept back", for: .normal)
            self.acceptButton.setTitleColor(UIColor.mainBlue(), for: .normal)
            self.acceptButton.isEnabled = true
            
        } else if status == 3 { // Mutually accepted
            
            self.acceptedStatusLabel.text = "This task is being completed by another Juggler"
            self.acceptButton.setTitle("In progress", for: .normal)
            self.acceptButton.setTitleColor(UIColor.mainBlue(), for: .normal)
            self.acceptButton.isEnabled = false
            
        } else if status == 4 { // Completed
            
            self.acceptedStatusLabel.text = "This task has been completed!"
            self.acceptButton.setTitle("Completed", for: .normal)
            self.acceptButton.setTitleColor(UIColor.mainAmarillo(), for: .normal)
            self.acceptButton.isEnabled = false
        }
    }
    
    var message: (Message?, User?) {
        didSet {
            guard let theMessage = message.0, let juggler = message.1 else {
                print("No message or user"); return
            }
            
            profileImageView.loadImage(from: juggler.profileImageURLString)
            fetchTaskFor(taskId: theMessage.taskId)
            nameLabel.text = juggler.firstName + " " + juggler.lastName
            messageTextLabel.text = theMessage.text
            timeLabel.text = theMessage.timeStamp.timeAgoDisplay()
        }
    }
    
    fileprivate func fetchTaskFor(taskId: String) {
        let taskRef = Database.database().reference().child(Constants.FirebaseDatabase.tasksRef).child(taskId)
        taskRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String : Any] else {
                self.task = nil
                print("Could not convert snapshot to [String : Any]"); return
            }
            
            let task = Task(id: snapshot.key, dictionary: dictionary)
            self.task = task
            
        }) { (error) in
            print("Error fetching task: ", error); return
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    @objc fileprivate func handleProfileImageView() {
        self.delegate?.handleProfileImageView(forJuggler: self.message.1)
    }
    
    let taskTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.mainBlue()
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    let messageTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        
        return label
    }()
    
    let acceptedStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textColor = .darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()

    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleAcceptedButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleAcceptedButton() {
        self.acceptButton.isEnabled = false
        self.acceptButton.setTitle("Loading...", for: .normal)
        
        delegate?.handleAcceptJuggler(forTask: self.task, juggler: self.message.1, completion: { (status) in
            self.updateAcceptedStatus(forStatus: status, userFirstName: self.message.1?.firstName ?? "This Juggler")
            if status == 3 {
                self.acceptedStatusLabel.text = "\(self.message.1?.firstName ?? "This Juggler") is in progress of completing your task!"
            }
        })
    }
    
    lazy var viewTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Task", for: .normal)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleViewTaskButton), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleViewTaskButton() {
        delegate?.handleViewTaskButton(forTask: self.task)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        let bottomSectionSeperatorView = UIView()
        bottomSectionSeperatorView.backgroundColor = UIColor.mainBlue().withAlphaComponent(0.5)
        
        addSubview(bottomSectionSeperatorView)
        bottomSectionSeperatorView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 100, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: nil, height: 1)
        
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
        
        addSubview(viewTaskButton)
        viewTaskButton.anchor(top: nil, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -8, width: 112, height: 25)
        viewTaskButton.layer.cornerRadius = 12
        viewTaskButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        addSubview(taskTitleLabel)
        taskTitleLabel.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 22)
        
        addSubview(nameLabel)
        nameLabel.anchor(top: taskTitleLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: viewTaskButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 20)
        
        addSubview(messageTextLabel)
        messageTextLabel.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: viewTaskButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: -8, width: nil, height: 20)
        
        addSubview(timeLabel)
        timeLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: bottomSectionSeperatorView.topAnchor, right: viewTaskButton.leftAnchor, paddingTop: 5, paddingLeft: 8, paddingBottom: -4, paddingRight: -8, width: nil, height: 20)
        
        addSubview(acceptButton)
        acceptButton.anchor(top: bottomSectionSeperatorView.topAnchor, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -8, width: 112, height: 25)
        acceptButton.layer.cornerRadius = 12
        
        addSubview(acceptedStatusLabel)
        acceptedStatusLabel.anchor(top: bottomSectionSeperatorView.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: acceptButton.leftAnchor, paddingTop: 4, paddingLeft: 16, paddingBottom: -4, paddingRight: -8, width: nil, height: nil)
        
        let bottomSeperatorView = UIView()
        bottomSeperatorView.backgroundColor = UIColor.mainBlue()
        addSubview(bottomSeperatorView)
        bottomSeperatorView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: nil, height: 1.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
